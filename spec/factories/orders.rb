FactoryBot.define do
  factory :order do
    sequence(:order_code, &:to_s)
    client
    status { 0 }
    price { '250' }
    frequency { 'Anual' }
    plan_id { 1 }
  end
end
