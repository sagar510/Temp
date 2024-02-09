FactoryBot.define do
    factory :mandi do
        association :dc, factory: :dc
        association :field_executive, factory: :user
        name { Faker::Company.name }
        gate_in_type { Mandi::GateInType::ALL.sample }
    end
end
  