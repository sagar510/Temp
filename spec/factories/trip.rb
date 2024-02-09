# == Schema Information
#
# Table name: trips
#
#  is_tracking_enabled         :boolean
#  tracking_details_json       :json
#  start_time                  :datetime
#  end_time                    :datetime
#

FactoryBot.define do
  factory :trip do
    trip_type {Trip::TripType::FRUIT}

    factory :no_vehicle_trip do
      trip_category {Trip::TripCategory::NO_VEHICLE}
    end

    factory :material_labour_trip do
      trip_type {Trip::TripType::MATERIAL_LABOUR}
      source factory: :farmer_purchase_order
      destination factory: :dc
    end

    vehicle_tonnage_max {Faker::Number.number(digits: 2)}
    transportation_cost_in_rs {10000}
    user factory: :logistics_manager_user
    start_time {Faker::Date.between(from: 2.days.ago, to: Date.today)}
    end_time {Faker::Date.forward(days: 23)}

    after(:create) do |trip|
      create:trip_meta_info, trip: trip
    end

    factory :unended_trip do
      after(:create) do |trip|
        pickup = create :pickup, trip: trip
        delivery = create :delivery, trip: trip
        shipment = create :farm_to_dc_shipment, pickup: pickup, delivery: delivery
        trip.update_columns(end_time: nil)
        trip.reload
      end
    end

    factory :trip_with_shipments do
      after(:create) do |trip|
        pickup = create :pickup, trip: trip
        delivery = create :delivery, trip: trip
        shipment = create :farm_to_dc_shipment, pickup: pickup, delivery: delivery
        delivery.update!(vehicle_arrival_time: Date.today + 30.minutes, status: Delivery::Status::UNLOADED)
        trip.reload
      end
    end

    factory :trip_with_advance_pr do
      after(:create) do |trip|
        create :advance_trip_payment_request, trip: trip
      end
    end

    factory :trip_with_advance_and_bill_pr do
      after(:create) do |trip|
        create :advance_trip_payment_request, trip: trip, amount: 1000
        create :bill_trip_payment_request, trip: trip, amount: 9000
      end
    end

  end
end
  
  
  