FactoryBot.define do
  factory :purchase_item do
    association :nfi_packaging_item, factory: :nfi_packaging_item

    factory :pi_pomo do
      weight_in_kgs { 110 }
      agreed_value  { 15 }
      product factory: :pomo
    end

    factory :pi_orange do
      weight_in_kgs { 110 }
      agreed_value  { 15 }
      product factory: :orange
    end

    factory :si_pomo do
      weight_in_kgs { 110 }
      agreed_value  { 15 }
      sku factory: :sku_pomo
    end

    factory :si_pomo_sb do
      weight_in_kgs { 110 }
      agreed_value  { 15 }
      sku factory: :sku_pomo_sb
    end

    factory :pi_kinnow do
      weight_in_kgs { 110 }
      agreed_value  { 15 }
      product factory: :kinnow
    end
  end
end