FactoryBot.define do
  factory :product do
    name { 'mail marketing' }
    group { 'MAIL' }
    plan { 'Marketing Básico' }
    frequency { 'Anual' }
    price { '250' }
    status { 0 }
    client
    order { create(:order, client: client) }
  end
end
