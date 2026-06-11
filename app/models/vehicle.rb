class Vehicle < ApplicationRecord
  VIN_LENGTH = 17

  include AccountScoped

  has_many :assignments, dependent: :destroy
  has_many :drivers, through: :assignments

  enum :status, { active: 0, in_shop: 1, retired: 2 }, default: :active
  enum :fuel_type, { gasoline: 0, diesel: 1, hybrid: 2, electric: 3, other: 4 }, prefix: true

  normalizes :vin, with: ->(vin) { vin.strip.upcase }
  normalizes :license_plate, with: ->(plate) { plate.strip.upcase }

  validates :vin, presence: true,
                  length: { is: VIN_LENGTH },
                  format: { with: /\A[A-HJ-NPR-Z0-9]+\z/, message: "contains invalid characters (I, O and Q are not used in VINs)" },
                  uniqueness: { scope: :account_id }
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: -> { Date.current.year + 1 } }, allow_nil: true
  validates :odometer, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :purchase_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :search, ->(query) {
    if query.present?
      term = "%#{sanitize_sql_like(query.strip)}%"
      where("vin LIKE :t OR make LIKE :t OR model LIKE :t OR license_plate LIKE :t", t: term)
    end
  }

  def current_assignment
    assignments.current.first
  end

  def current_driver
    current_assignment&.driver
  end

  def display_name
    [ year, make, model ].compact.join(" ").presence || vin
  end
end
