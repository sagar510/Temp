FactoryBot.define do
  factory :delivery do
    dc factory: :dc
    delivery_order {1}
    trip factory: :trip
    challan { Rack::Test::UploadedFile.new(Rails.root.to_s + '/public/logo_192.png', 'image/png') }
    vehicle_arrival_time { }
    
    factory :delivery_hyd_dc do
      dc factory: :hyd_dc
      delivery_order {1}
      trip factory: :trip
      
    end

    factory :delivery_with_customer_amount do
      customer_amount {100}
    end
  end
end