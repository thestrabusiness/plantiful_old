FactoryBot.define do
  factory :user do
    first_name { 'Uncle' }
    sequence(:last_name) { |n| "Tony #{n}" }
    sequence(:email) { |n| "uncletony#{n}@example.com" }
    password { 'password' }
    garden

    trait :with_plants do
      transient do
        number { 3 }
      end

      after :create do |user, evaluator|
        evaluator
          .number
          .times { create(:plant, added_by: user, garden: user.garden) }
      end
    end
  end
end
