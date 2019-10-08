FactoryBot.define do
  factory :garden do
    name { 'Garden' }
    association :owner, factory: :user

    trait :with_users do
      after(:create) do |garden, _|
        garden.users << create_list(:user, 2)
      end
    end
  end
end
