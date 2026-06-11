class User < ApplicationRecord
  include AccountScoped

  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { viewer: 0, manager: 1, admin: 2 }, default: :viewer

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
end
