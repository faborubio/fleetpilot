module Alerts
  # Scans one account's vehicles and drivers and reconciles its Alert records:
  # creates/updates an open alert when a condition holds, dismisses it when it
  # no longer does. Idempotent — running it repeatedly converges to the same set.
  class Scanner
    Desired = Data.define(:category, :severity, :message, :due_on)

    def self.call(account)
      new(account).call
    end

    def initialize(account)
      @account = account
    end

    # Returns the alerts that are currently open after reconciliation.
    def call
      reconcile_renewals
      reconcile_maintenance
      reconcile_licenses
      account.alerts.active
    end

    private

    attr_reader :account

    def reconcile_renewals
      account.renewals.includes(:vehicle).find_each do |renewal|
        desired =
          if renewal.expired?
            Desired.new(:renewal_expired, :critical,
                        "#{renewal.kind.humanize} for #{renewal.vehicle.display_name} expired on #{renewal.expires_on.to_fs(:long)}",
                        renewal.expires_on)
          elsif renewal.due_soon?
            Desired.new(:renewal_due_soon, :warning,
                        "#{renewal.kind.humanize} for #{renewal.vehicle.display_name} expires on #{renewal.expires_on.to_fs(:long)}",
                        renewal.expires_on)
          end
        reconcile(renewal, desired)
      end
    end

    def reconcile_maintenance
      account.maintenance_schedules.includes(:vehicle).find_each do |schedule|
        desired =
          if schedule.due?
            Desired.new(:maintenance_due, :warning,
                        "#{schedule.category.humanize} due for #{schedule.vehicle.display_name}",
                        schedule.next_due_on)
          elsif schedule.due_soon?
            Desired.new(:maintenance_due_soon, :info,
                        "#{schedule.category.humanize} coming up for #{schedule.vehicle.display_name}",
                        schedule.next_due_on)
          end
        reconcile(schedule, desired)
      end
    end

    def reconcile_licenses
      account.drivers.find_each do |driver|
        next if driver.license_expires_on.blank?

        desired =
          if driver.license_expired?
            Desired.new(:license_expired, :critical,
                        "#{driver.name}'s license expired on #{driver.license_expires_on.to_fs(:long)}",
                        driver.license_expires_on)
          elsif driver.license_expires_on <= Date.current + Driver::DUE_SOON_DAYS.days
            Desired.new(:license_due_soon, :warning,
                        "#{driver.name}'s license expires on #{driver.license_expires_on.to_fs(:long)}",
                        driver.license_expires_on)
          end
        reconcile(driver, desired)
      end
    end

    # Enforces one open alert per (source, category): updates a matching open
    # alert, creates one if absent, and dismisses any stale open alerts on the
    # same source whose category no longer applies.
    def reconcile(source, desired)
      open_alerts = source.alerts.active.to_a

      if desired
        alert = open_alerts.find { |a| a.category == desired.category.to_s }
        if alert
          alert.update!(severity: desired.severity, message: desired.message, due_on: desired.due_on)
        else
          account.alerts.create!(
            alertable: source, category: desired.category, severity: desired.severity,
            status: :pending, message: desired.message, due_on: desired.due_on
          )
        end
        open_alerts.reject { |a| a.category == desired.category.to_s }.each(&:dismiss!)
      else
        open_alerts.each(&:dismiss!)
      end
    end
  end
end
