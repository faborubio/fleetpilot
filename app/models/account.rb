class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :drivers, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :name, presence: true
end
