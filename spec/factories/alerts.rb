FactoryBot.define do
  factory :alert do
    account
    alertable { association :renewal, account: account }
    category { :renewal_expired }
    severity { :critical }
    status { :pending }
    message { "Insurance expired" }
    due_on { Date.current }
  end
end
