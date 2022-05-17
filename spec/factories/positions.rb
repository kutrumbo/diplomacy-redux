FactoryBot.define do
  factory :position do
    area
    nationality { Position::NATIONALITIES.sample }
    unit_type { Position::UNIT_TYPES.sample }
  end
end
