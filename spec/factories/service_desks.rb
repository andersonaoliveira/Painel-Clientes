FactoryBot.define do
  factory :service_desk do
    category { nil }
    client { nil }
    order { nil }
    status { 0 }
    description { 'Meu produto não está instalado' }
    admin { nil }
  end
end
