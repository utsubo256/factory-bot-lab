FactoryBot.define do
  factory :post do
    title { "First post" }
    association :user
  end
end
