FactoryBot.define do
  factory :chamber do
    chamber_type factory: :chamber_type
    name {"Operations Area "+rand(1...10).to_s}
    capacity {10000}
    active {true}
    dc factory: :hyd_dc

    factory :zone_chamber do
      chamber_type factory: :zone
      name {"Zone 1"}
    end
  end
end
