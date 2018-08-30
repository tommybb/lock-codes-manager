FactoryBot.define do
  factory :guest do
    roomy_id { Faker::Number.unique.within(1..999) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { '+48604633888' }
    email { Faker::Internet.email }
  end
end
