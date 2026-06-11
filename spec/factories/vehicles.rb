FactoryBot.define do
  factory :vehicle do
    account
    sequence(:vin) { |n| "1HGCM82633A#{n.to_s.rjust(6, '0')}" }
    make { "Honda" }
    model { "Accord" }
    year { 2022 }
    sequence(:license_plate) { |n| "FLT#{n.to_s.rjust(4, '0')}" }
    status { :active }
    odometer { 12_500 }
  end
end
