FactoryBot.define do
  factory :area do
    name { Faker::Address.country }
    area_type { Area::AREA_TYPES.sample }
    supply_center { [true, false].sample }

    trait :land do
      area_type { Area::LAND }
    end

    trait :sea do
      area_type { Area::SEA }
    end
  end
end
