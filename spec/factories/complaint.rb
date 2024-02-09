FactoryBot.define do
  factory :complaint do
    sale_order_item factory: :soi_pomo
    quality_issue factory: :quality_issue
    description { 'custom complaint' }
  end
end
