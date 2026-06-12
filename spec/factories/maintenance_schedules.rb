FactoryBot.define do
  factory :maintenance_schedule do
    account
    vehicle { association :vehicle, account: account }
    category { :oil_change }
    interval_months { 6 }
    interval_miles { 5_000 }
    last_performed_on { 3.months.ago.to_date }
    last_performed_odometer { 25_000 }
  end
end
