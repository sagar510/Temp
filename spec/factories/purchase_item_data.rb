FactoryBot.define do
    factory :purchase_item_data do
      association :purchase_item 
      inventory_kgs { 100.0 } 
      sold_weight_kgs { 80.0 } 
      loss_kgs { 20.0 } 
      selling_price_per_kg { 10.0 }
      patti_price_per_kg { 8.0 } 
      logistics_cost { 5.0 } 
    end
end