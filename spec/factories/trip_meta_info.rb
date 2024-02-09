FactoryBot.define do
  factory :trip_meta_info do
    trip factory: :trip
    partner factory: :transporter_with_kyc_and_bank_detail

    driver_details_json {{"name": Faker::Name.first_name, "phone": Faker::PhoneNumber.cell_phone_in_e164}}
    vehicle_details_json {{"type": Faker::Vehicle.make_and_model, "number": Faker::Vehicle.license_plate}}

    transportation_cost_in_rs {10000}
    is_tracking_enabled {false}
    trip_order {1}

    vehicle_rc { Rack::Test::UploadedFile.new(Rails.root.to_s + '/public/logo_192.png', 'image/png') }
    driver_license { Rack::Test::UploadedFile.new(Rails.root.to_s + '/public/logo_192.png', 'image/png') }
  end
end
