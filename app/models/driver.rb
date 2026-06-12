class Driver < ApplicationRecord
  DUE_SOON_DAYS = 30

  include AccountScoped

  has_many :assignments, dependent: :destroy
  has_many :vehicles, through: :assignments
  has_many :alerts, as: :alertable, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }, default: :active

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :search, ->(query) {
    if query.present?
      term = "%#{sanitize_sql_like(query.strip)}%"
      where("name LIKE :t OR email LIKE :t OR license_number LIKE :t", t: term)
    end
  }

  def license_expired?
    license_expires_on.present? && license_expires_on.past?
  end

  def current_assignment
    assignments.current.first
  end

  def current_vehicle
    current_assignment&.vehicle
  end
end
