FactoryBot.define do
  factory :mo_item_to_so_item do
    material_order_item {create(:moi_pomo)}
    sale_order_item {create(:soi_pomo)}
  end
end