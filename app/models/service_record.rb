class ServiceRecord < ApplicationRecord
  include AccountScoped

  belongs_to :vehicle

  CATEGORIES = { oil_change: 0, tires: 1, brakes: 2, inspection: 3, repair: 4, other: 5 }.freeze
  enum :category, CATEGORIES, default: :other

  validates :performed_on, presence: true
  validates :odometer, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cost_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  after_commit :refresh_matching_schedule, on: %i[create update]

  scope :recent_first, -> { order(performed_on: :desc) }

  private

  # Keep the matching maintenance schedule's "last performed" markers in sync
  # so the next-due calculation reflects the latest service.
  def refresh_matching_schedule
    schedule = vehicle.maintenance_schedules.find_by(category: category)
    schedule&.record_service(performed_on:, odometer:)
  end
end
