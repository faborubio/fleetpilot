FactoryBot.define do
  factory :service_record do
    account
    vehicle { association :vehicle, account: account }
    category { :oil_change }
    performed_on { Date.current }
    odometer { 30_000 }
    cost_cents { 8_900 }
    vendor { "Quick Lube" }
  end
end
