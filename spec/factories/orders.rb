FactoryBot.define do
  factory :order do
    position
    order_type { Order::HOLD }
  end
end
