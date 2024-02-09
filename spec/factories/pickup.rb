FactoryBot.define do
  factory :pickup do
    vehicle_arrival_time { nil }
    pickup_order {1}
    trip factory: :trip
  end
end