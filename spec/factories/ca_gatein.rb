FactoryBot.define do
  factory :ca_gatein do
    association :dc, factory: :ph_dc
    association :user, factory: :user
    inward_type { "Crates" }
    purchase_type { CaGatein::PurchaseType::MIX }
    model { CaGatein::Model::FIXED }
    vehicle_number { Faker::Vehicle.license_plate }
    driver_phone_number { Faker::PhoneNumber.phone_number }

    factory :ca_gatein_with_farmers_and_items do
      transient do
        farmers_count { 1 }
        items_count { 3 }
      end

      after(:create) do |ca_gatein, evaluator|
        farmer = create(:farmer)
        create_list(:ca_gatein_farmer, evaluator.farmers_count, ca_gatein: ca_gatein, farmer: farmer).each do |ca_farmer|
          create_list(:ca_farmer_token, evaluator.farmers_count, ca_gatein_farmer: ca_farmer, dc: ca_gatein.dc)
          create_list(:ca_gatein_item, evaluator.items_count, ca_gatein_farmer: ca_farmer)
        end
      end
    end
  end
end
