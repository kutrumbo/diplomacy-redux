FactoryBot.define do
  factory :border do
    area
    association :neighbor, factory: :area
  end
end
