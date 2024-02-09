FactoryBot.define do
  factory :sale_order_bill do
    number { Faker::Number.number(digits: 10) }
    sale_order {create(:indirect_sale)}
  end
end