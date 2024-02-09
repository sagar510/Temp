FactoryBot.define do
  factory :customer do
    name {Faker::Name.first_name}
    customer_type {Customer::Type::GT}
    poc_phone_number { Faker::PhoneNumber.unique.subscriber_number(length: 10) }
    after(:create) do |customer|
      customer.locations << Location.create_from_address!({:full_address=>"Bangalore"})
      customer.save!
    end
    factory (:customer_gt) do
      customer_type {Customer::Type::GT}
    end

    factory (:customer_mt) do
      customer_type {Customer::Type::MT}
    end

    factory (:customer_exp) do
      customer_type {Customer::Type::EXPORTER}
    end

    factory (:customer_lq) do
      customer_type {Customer::Type::LQ}
    end
  end
end