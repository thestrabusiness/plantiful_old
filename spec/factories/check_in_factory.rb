FactoryBot.define do
  factory :check_in do
    fertilized { false }
    watered { false }
    plant

    trait :watered do
      watered { true }
    end

    trait :fertilized do
      fertilized { true }
    end
  end
end
