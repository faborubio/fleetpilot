class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :drivers, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :service_records, dependent: :destroy
  has_many :maintenance_schedules, dependent: :destroy
  has_many :renewals, dependent: :destroy
  has_many :alerts, dependent: :destroy

  validates :name, presence: true
end
