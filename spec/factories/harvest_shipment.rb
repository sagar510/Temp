FactoryBot.define do
    factory :harvest_shipment do
        harvest factory: :child_harvest
        shipment factory: :farm_to_dc_shipment
    end

end