FactoryBot.define do
    factory :market_price do
      dc factory: :hyd_dc
      sku factory: :sku
      user factory: :market_intelligence_exec
      price { 108.0}
      date { '2021-01-01' }
    end
  end