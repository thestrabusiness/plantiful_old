FactoryBot.define do
  factory :plant do
    association :added_by, factory: :user
    check_frequency_scalar { 1 }
    check_frequency_unit { 'day' }
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

    trait :deleted do
      deleted_at { 1.day.ago }
    end

    after(:build) do |plant, _|
      if plant.garden.nil?
        plant.garden = plant.added_by.owned_gardens.first
      end
    end
  end
end
