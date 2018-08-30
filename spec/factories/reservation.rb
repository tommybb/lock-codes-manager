FactoryBot.define do
  factory :reservation do
    roomy_id { Faker::Number.unique.within(1..9999999) }
    room
    guest
    checkin_date { 15.days.from_now }
    checkout_date { 18.days.from_now }
    booked_at { 10.days.ago }
    cancelled { false }
    room_lock_pin_code { Faker::Number.unique.within(1..9999) }
  end
end
