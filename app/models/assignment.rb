class Assignment < ApplicationRecord
  include AccountScoped

  belongs_to :vehicle
  belongs_to :driver

  scope :current, -> { where(ended_on: nil).or(where(ended_on: Date.current..)) }
  scope :overlapping, ->(starts, ends) {
    if ends.nil?
      where("ended_on IS NULL OR ended_on >= ?", starts)
    else
      where("started_on <= ?", ends).where("ended_on IS NULL OR ended_on >= ?", starts)
    end
  }

  validates :started_on, presence: true
  validates :ended_on, comparison: { greater_than_or_equal_to: :started_on }, allow_nil: true
  validate :vehicle_and_driver_belong_to_account
  validate :no_overlap_for_vehicle
  validate :no_overlap_for_driver

  def current?
    ended_on.nil? || !ended_on.past?
  end

  private

  def vehicle_and_driver_belong_to_account
    errors.add(:vehicle, "belongs to another account") if vehicle && vehicle.account_id != account_id
    errors.add(:driver, "belongs to another account") if driver && driver.account_id != account_id
  end

  def no_overlap_for_vehicle
    return if vehicle.nil? || started_on.nil?

    if vehicle.assignments.where.not(id: id).overlapping(started_on, ended_on).exists?
      errors.add(:vehicle, "is already assigned during this period")
    end
  end

  def no_overlap_for_driver
    return if driver.nil? || started_on.nil?

    if driver.assignments.where.not(id: id).overlapping(started_on, ended_on).exists?
      errors.add(:driver, "is already assigned during this period")
    end
  end
end
