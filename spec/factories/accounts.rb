FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Acme Logistics #{n}" }
  end
end
