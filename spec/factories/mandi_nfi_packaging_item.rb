FactoryBot.define do
    factory :mandi_nfi_packaging_item do
      association :mandi, factory: :mandi
      association :nfi_packaging_item, factory: :nfi_packaging_item
      rate { Faker::Commerce.price(range: 0..100.0) }
      gst { [5, 12, 18, 28, -1].sample }
    end
  end