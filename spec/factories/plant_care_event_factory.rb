FactoryBot.define do
  factory :plant_care_event do
    happened_at { Time.current }
    plant

    factory :watering do
      kind { 'watering' }
    end

    factory :check do
      kind { 'check' }
    end
  end
end
