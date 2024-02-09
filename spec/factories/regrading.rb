FactoryBot.define do
  factory :regrading do
    regrade_tracker factory: :regrade_tracker_for_regrade
    lot factory: :dc_lot
    weight {20}
    factory :input_regrading do
      lot_type {Regrading::LotType::INPUT}
    end
    factory :output_regrading do
      lot_type {Regrading::LotType::OUTPUT}
    end
  end
end
