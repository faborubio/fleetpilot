FactoryBot.define do
  factory :renewal do
    account
    vehicle { association :vehicle, account: account }
    kind { :insurance }
    expires_on { 1.year.from_now.to_date }
  end
end
