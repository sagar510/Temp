FactoryBot.define do
    factory :packaging_type do
        name { Faker::Commerce.unique.product_name }
        code { Faker::Alphanumeric.unique.alphanumeric(number: 10) }
        empty_weight { Faker::Number.decimal(l_digits: 2) }
        capacity { Faker::Number.decimal(l_digits: 2) }
        cost_per_unit { Faker::Number.decimal(l_digits: 2) }
        other_cost { Faker::Number.decimal(l_digits: 2) }
        total_cost_per_kg { Faker::Number.decimal(l_digits: 2) }
    end
end