FactoryBot.define do
  factory :user do
    name { "Alice" }
    sequence(:email) { |n| "user#{n}@example.com" }

    trait :admin do
      admin { true }
    end
  end
end
