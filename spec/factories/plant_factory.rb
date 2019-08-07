FactoryBot.define do
  factory :plant do
    sequence(:name) { |n| "Plant #{n}" }
    user
    check_frequency_scalar { 1 }
    check_frequency_unit { 'day' }

    trait :with_weekly_check do
      check_frequency_scalar { 1 }
      check_frequency_unit { 'week' }
    end

    trait :with_waterings do
      transient do
        number { 2 }
      end

      after :create do |plant, evaluator|
        create_list(:watering, number, plant: plant)
      end
    end
  end
end
