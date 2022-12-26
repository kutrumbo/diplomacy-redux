FactoryBot.define do
  factory :turn do
    game
    type { Turn::SPRING }
    number { 1 }
  end
end
