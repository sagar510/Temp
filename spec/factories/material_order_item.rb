FactoryBot.define do
  factory :material_order_item do
    material_order { create(:material_order_for_central_sale_order) }
    ordered_weight { Faker::Number.number(digits: 4) }
    average_weight { Faker::Number.number(digits: 4) }
    sale_order_item { create(:soi_pomo) }
    factory :moi_pomo do
      sku { create(:sku_pomo)}
    end
  end

  factory :moi_for_amo, class: MaterialOrderItem do
    material_order factory: :mo_for_amo
    ordered_weight { Faker::Number.number(digits: 4) }
    average_weight { Faker::Number.number(digits: 4) }
    order_type { MaterialOrderItem::OrderType::KG }
    sku factory: :sku_pomo

    factory :moi_with_soi_for_amo do
      sale_order_items { create_list :soi_for_amo ,1 }
    end

    factory :moi_with_allotment do
      after(:create) do |material_order_item|
        create :lot, material_order_item: material_order_item, initial_weight: 20
      end
    end

    factory :moi_for_amo_unit_order_type do
      average_weight { 10.0 }
      ordered_units { 3 }
      ordered_weight { average_weight * ordered_units }
      order_type { MaterialOrderItem::OrderType::UNIT }
    end
  end

  factory :moi_for_amo_with_unit_order_type, class: MaterialOrderItem do
    material_order factory: :mo_for_amo
    ordered_weight { 30.0 }
    ordered_units { 3 }
    average_weight { 10.0 }
    order_type { MaterialOrderItem::OrderType::UNIT }
    sku factory: :sku_pomo

    factory :moi_with_allotment_unit_order_type do
      transient do
        initial_weight { 20.0 }
      end

      after(:create) do |material_order_item, transients|
        create :lot, material_order_item: material_order_item, initial_weight: transients.initial_weight
      end
    end
  end

end