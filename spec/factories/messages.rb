FactoryBot.define do
  factory :message do
    author_type { 1 }
    content { 'MyString' }
    service_desk { nil }
  end
end
