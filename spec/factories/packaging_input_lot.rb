FactoryBot.define do
  factory :packaging_input_lot, class: Qr::PackagingInputLot do
    transient do
      chamber { create(:chamber) }
    end

    packaging_process { create(:packaging_process, chamber: chamber) }
    lot { create(:standard_dc_lot, chamber: chamber) }

    quantity { Faker::Number.between(from: 1, to: 5) }
  end
end