FactoryBot.define do
  factory :user do
    account
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :manager }

    trait :admin do
      role { :admin }
    end

    trait :viewer do
      role { :viewer }
    end
  end
end
