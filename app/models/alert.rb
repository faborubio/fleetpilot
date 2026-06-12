class Alert < ApplicationRecord
  include AccountScoped

  belongs_to :alertable, polymorphic: true

  enum :category, {
    renewal_expired: 0, renewal_due_soon: 1,
    maintenance_due: 2, maintenance_due_soon: 3,
    license_expired: 4, license_due_soon: 5
  }, prefix: true

  enum :severity, { info: 0, warning: 1, critical: 2 }, prefix: true
  enum :status, { pending: 0, sent: 1, dismissed: 2 }, prefix: true

  validates :message, presence: true

  scope :open, -> { where.not(status: :dismissed) }
  scope :active, -> { where(status: %i[pending sent]) }
  scope :by_urgency, -> { order(severity: :desc, due_on: :asc) }

  def dismiss!
    update!(status: :dismissed)
  end
end
