FactoryBot.define do
  factory :resolution do
    status { Resolution::STATUSES.sample }
    order
  end
end
