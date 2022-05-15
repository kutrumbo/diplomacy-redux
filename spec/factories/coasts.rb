FactoryBot.define do
  factory :coast do
    area
    direction { Coast::DIRECTIONS.sample }
  end
end
