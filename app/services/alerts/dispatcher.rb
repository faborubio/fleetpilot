module Alerts
  # Delivers an account's pending alerts: emails a digest to users who opted in,
  # then marks the alerts as sent so they are not emailed again. In-app delivery
  # needs no work here — alerts are already queryable from the database.
  class Dispatcher
    def self.call(account)
      new(account).call
    end

    def initialize(account)
      @account = account
    end

    def call
      pending = @account.alerts.status_pending.by_urgency.to_a
      return 0 if pending.empty?

      notify_users(pending)
      Alert.where(id: pending.map(&:id)).update_all(status: :sent, updated_at: Time.current)
      pending.size
    end

    private

    def notify_users(alerts)
      recipients = @account.users.where(notify_by_email: true)
      recipients.find_each do |user|
        AlertsMailer.digest(user, alerts.map(&:id)).deliver_later
      end
    end
  end
end
