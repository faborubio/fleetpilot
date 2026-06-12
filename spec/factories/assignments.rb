FactoryBot.define do
  factory :assignment do
    account
    vehicle { association :vehicle, account: account }
    driver { association :driver, account: account }
    started_on { Date.current }
    ended_on { nil }
  end
end
