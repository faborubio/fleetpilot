class MaintenanceSchedule < ApplicationRecord
  include AccountScoped

  belongs_to :vehicle
  has_many :alerts, as: :alertable, dependent: :destroy

  # Soon to be due: surfaces upcoming maintenance before it is overdue.
  DUE_SOON_DAYS = 30
  DUE_SOON_MILES = 1_000

  enum :category, ServiceRecord::CATEGORIES, default: :oil_change

  validates :category, uniqueness: { scope: :vehicle_id }
  validates :interval_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :interval_miles, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :at_least_one_interval

  def record_service(performed_on:, odometer:)
    self.last_performed_on = performed_on if performed_on
    self.last_performed_odometer = odometer if odometer
    save!
  end

  def next_due_on
    return nil if interval_months.blank? || last_performed_on.blank?

    last_performed_on + interval_months.months
  end

  def next_due_odometer
    return nil if interval_miles.blank? || last_performed_odometer.blank?

    last_performed_odometer + interval_miles
  end

  # Due when either the time-based or mileage-based threshold has passed.
  def due?(as_of: Date.current, odometer: vehicle.odometer)
    due_by_date?(as_of) || due_by_mileage?(odometer)
  end

  def due_soon?(as_of: Date.current, odometer: vehicle.odometer)
    return false if due?(as_of:, odometer:)

    (next_due_on.present? && next_due_on <= as_of + DUE_SOON_DAYS.days) ||
      (next_due_odometer.present? && next_due_odometer <= odometer + DUE_SOON_MILES)
  end

  private

  def due_by_date?(as_of)
    next_due_on.present? && next_due_on <= as_of
  end

  def due_by_mileage?(odometer)
    next_due_odometer.present? && odometer.present? && odometer >= next_due_odometer
  end

  def at_least_one_interval
    if interval_months.blank? && interval_miles.blank?
      errors.add(:base, "set an interval in months, miles, or both")
    end
  end
end
