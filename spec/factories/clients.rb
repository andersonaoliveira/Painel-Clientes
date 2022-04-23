FactoryBot.define do
  factory :client do
    name { 'João' }
    email { 'joao@campus.com' }
    eni { '33256256870' }
    password { '123456' }
  end
end
