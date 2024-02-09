FactoryBot.define do
  factory :packaging_process, class: Qr::PackagingProcess do
    regrade_tracker { create(:regrade_tracker_for_allot_to_sale_order_item) } #To-Do : after adding regrading flow
    status { Qr::PackagingProcess::Status::IN_PROGRESS }
    # association :chamber, factory: :chamber
    chamber { create(:chamber) }
    association :product, factory: :pomo
    #product { FactoryBot.build([:pomo, :orange, :grapes].sample) }
    grade_c_weight { Faker::Number::between(from: 1.0, to: 10.0) }
    moisture_loss { Faker::Number::between(from: 0.0, to: 5.0) }
    comments { 'Testing...' }
    association :created_by, factory: :user
    association :updated_by, factory: :user

    transient do
      input_lots_count { 1 }
      output_lots_count { 1 }
    end

    factory :packaging_process_with_input_lots do
      after(:create) do |packaging_process, evaluator|
        create_list(:packaging_input_lot, evaluator.input_lots_count, packaging_process: packaging_process, chamber: evaluator.chamber)
      end
    end 

    factory :packaging_process_with_output_lots do
      after(:create) do |packaging_process, evaluator|
        create_list(:packaging_output_lot, evaluator.output_lots_count, 
        packaging_process: packaging_process,
        lot_type: Lot::LotType::STANDARD,
        sku: create(:sku,product: packaging_process.product)
        )
      end
    end 
  end
end