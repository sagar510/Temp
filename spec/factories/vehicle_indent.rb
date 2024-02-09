FactoryBot.define do
  factory :vehicle_indent do
    shipment { create(:dc_to_dc_shipment) }
    expected_delivery_time { DateTime.now + 6.hours }
    expected_loading_time { DateTime.now + 3.hours }
    indent_created_time { DateTime.now }
  end
end