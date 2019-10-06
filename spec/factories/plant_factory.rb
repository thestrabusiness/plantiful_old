FactoryBot.define do
  factory :plant do
    association :added_by, factory: :user
    check_frequency_scalar { 1 }
    check_frequency_unit { 'day' }
    garden
    sequence(:name) { |n| "Plant #{n}" }

    trait :with_weekly_check do
      check_frequency_scalar { 1 }
      check_frequency_unit { 'week' }
    end

    trait :with_waterings do
      after :create do |plant, _evaluator|
        create_list(:check_in, 5, :watered, plant: plant)
      end
    end

    after(:build) do |plant, _|
      plant.added_by.update(garden: plant.garden)
    end
  end
end
