FactoryBot.define do
    factory :mandi_satellite_cc do
      association :mandi, factory: :mandi
      association :dc, factory: :dc
      calculation_logic {"KG"}
      value { Faker::Commerce.price(range: 0..100.0) }
    end
  end