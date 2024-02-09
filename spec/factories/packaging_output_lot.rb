FactoryBot.define do
  factory :packaging_output_lot, class: Qr::PackagingOutputLot do
    association :packaging_process, factory: :packaging_process
    association :sku, factory: :random_grade_pomo_sku
    association :nfi_packaging_item, factory: :nfi_packaging_item
    #association :lot, factory: :standard_dc_lot

    lot_type { Lot::LotType::STANDARD }
    quantity { Faker::Number.between(from: 1, to: 5) }
    average_weight { Faker::Number.decimal(l_digits: 1) }
  end
end