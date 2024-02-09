FactoryBot.define do
  factory :sale_order_item do
    sale_order { create(:sale_order) }
    price {15}
    target_price {15}
    discount_type {'Others'}
    ordered_weight { Faker::Number.number(digits: 4) }
    average_weight { Faker::Number.number(digits: 4) }
    sale_unit {1}
    factory :soi_pomo do
      sku { create(:sku_pomo)}
    end
    factory :soi_pomo_sb do
      sku { create(:sku_pomo_sb)}
    end
    factory :cso_soi_pomo do
      sale_order { create(:central_sale_order) }
      sku { create(:sku_pomo)}
    end
  end

  factory :soi_for_amo, class: SaleOrderItem do
    sale_order factory: :so_for_amo
    price {10}
    target_price {15}
    discount_type {'Others'}
    ordered_weight { 10 }
    average_weight { 10 }
    sku factory: :sku_pomo

    factory :soi_with_moi_for_amo do
      material_order_items { create_list :moi_for_amo ,1 }
    end
  end

end