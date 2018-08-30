FactoryBot.define do
  factory :room do
    roomy_id { Faker::Number.unique.within(1..850) }
    number { Faker::Number.unique.within(1..850) }
    lock_uuid { SecureRandom.uuid }
  end
end
