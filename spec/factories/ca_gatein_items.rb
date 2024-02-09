FactoryBot.define do
  factory :ca_gatein_item do
    association :product, factory: :pomo
    association :sku, factory: :sku_pomo
    association :ca_gatein_farmer, factory: :ca_gatein_farmer
    status { CaGateinItem::Status::GRADED }
    weight { 10.0 }
    units { 5 }
  end
end
