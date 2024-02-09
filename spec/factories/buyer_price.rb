FactoryBot.define do
  factory :buyer_price do
    sku factory: :sku
    micro_pocket factory: :micro_pocket
    price {Faker::Number.number(digits: 2)}
    factory (:current_buyer_price) do
      price_date {Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)}
    end

    factory (:upcoming_buyer_price) do
      price_date {Faker::Time.between(from: DateTime.now + 1, to: DateTime.now + 10)}
    end

    factory (:previous_buyer_price) do
      price_date {Faker::Time.between(from: DateTime.now - 10, to: DateTime.now - 1)}
    end
  end
end
