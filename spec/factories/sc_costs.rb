FactoryBot.define do
    factory :sc_cost, class: ScCost do
      association :product_category, factory: :pomo_product_category
      association :cost_head, factory: :fruit_ch
      price        {rand(1..100)}
      start_date { Faker::Date.between(from: Date.today - 1.year, to: Date.today) }     
    end
  end