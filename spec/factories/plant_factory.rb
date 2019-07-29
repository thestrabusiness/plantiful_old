FactoryBot.define do
  factory :plant do
    sequence(:name) { |n| "Plant #{n}" }
    user
  end
end