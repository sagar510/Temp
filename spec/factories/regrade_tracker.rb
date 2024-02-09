FactoryBot.define do
  factory :regrade_tracker do
    user factory: :dc_executive_user
    dc { FactoryBot.create(:hyd_dc) }
    product factory: :pomo
    start_time { DateTime.new(2020, 10, 10, 10, 10, 10) }
    end_time { DateTime.new(2020, 10, 10, 10, 10, 50) }
  
    before(:create) do |regrade_tracker|
      chamber = FactoryBot.create(:chamber, dc: regrade_tracker.dc)
      regrade_tracker.chamber_id = chamber.id
    end
    
    factory :regrade_tracker_for_regrade do
      comments {"Regrade Tracker for Regrade"}
      moisture_loss {5}
      grade_c_weight {0}
      tracker_type {RegradeTracker::TrackerType::REGRADE}
      after(:create) do |regrade_tracker|
        create :input_regrading, regrade_tracker: regrade_tracker, weight: 25
        create :input_regrading, regrade_tracker: regrade_tracker, weight: 30
        create :output_regrading, regrade_tracker: regrade_tracker, weight: 50
      end
    end

    factory :regrade_tracker_for_merge do
      comments {"Regrade Tracker for Merge"}
      moisture_loss {0}
      grade_c_weight {0}
      tracker_type {RegradeTracker::TrackerType::MERGE}
      after(:create) do |regrade_tracker|
        create :input_regrading, regrade_tracker: regrade_tracker, weight: 20
        create :input_regrading, regrade_tracker: regrade_tracker, weight: 30
        create :output_regrading, regrade_tracker: regrade_tracker, weight: 50
      end
    end

    factory :regrade_tracker_for_allot_to_sale_order_item do
      comments {"Regrade Tracker for Allot to Sale Order Item"}
      moisture_loss {0}
      grade_c_weight {0}
      sale_order_item factory: :soi_pomo
      tracker_type {RegradeTracker::TrackerType::AllotToSaleOrderItem}
      after(:create) do |regrade_tracker|
        create :input_regrading, regrade_tracker: regrade_tracker, weight: 20
        create :input_regrading, regrade_tracker: regrade_tracker, weight: 30
        create :output_regrading, regrade_tracker: regrade_tracker, weight: 50
      end
    end

    factory :regrade_tracker_for_allot_to_material_order_shipment do
      comments {"Regrade Tracker for Allot to Material Order Shipment"}
      moisture_loss {0}
      grade_c_weight {0}
      tracker_type {RegradeTracker::TrackerType::AllotToMaterialOrderShipment}
    end
  end
end
