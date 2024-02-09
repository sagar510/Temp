FactoryBot.define do
  factory :seller_price do
    sku factory: :sku
    dc factory: :dc
    price {Faker::Number.number(digits: 2)}
    factory (:current_seller_price) do
      price_date {Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)}
    end

    factory (:upcoming_seller_price) do
      price_date {Faker::Time.between(from: DateTime.now + 1, to: DateTime.now + 10)}
    end

    factory (:previous_seller_price) do
      price_date {Faker::Time.between(from: DateTime.now - 10, to: DateTime.now - 1)}
    end
  end
end
