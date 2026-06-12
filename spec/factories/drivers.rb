FactoryBot.define do
  factory :driver do
    account
    name { Faker::Name.name }
    sequence(:email) { |n| "driver#{n}@example.com" }
    phone { "+15555550100" }
    sequence(:license_number) { |n| "DL#{n.to_s.rjust(7, '0')}" }
    license_expires_on { 2.years.from_now.to_date }
    status { :active }
  end
end
