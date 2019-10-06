FactoryBot.define do
  factory :garden do
    name { 'Garden' }

    trait :with_users do
      after(:create) do |garden, _|
        2.times { create(:user, garden: garden) }
      end
    end
  end
end
