class Renewal < ApplicationRecord
  include AccountScoped

  belongs_to :vehicle
  has_many :alerts, as: :alertable, dependent: :destroy

  DUE_SOON_DAYS = 30

  enum :kind, { insurance: 0, registration: 1, inspection: 2 }, default: :insurance

  validates :kind, uniqueness: { scope: :vehicle_id }
  validates :expires_on, presence: true

  scope :expiring_before, ->(date) { where(expires_on: ..date) }

  def expired?(as_of: Date.current)
    expires_on < as_of
  end

  def due_soon?(as_of: Date.current)
    !expired?(as_of:) && expires_on <= as_of + DUE_SOON_DAYS.days
  end
end
