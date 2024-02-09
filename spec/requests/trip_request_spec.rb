require 'rails_helper'
require_relative '../support/devise'

RSpec.describe TripsController, type: :request do
    before(:all) do
        @newTrip = FactoryBot.create(:trip)
    end

    describe "CRUD on trip" do
        login_admin

        it 'create a trip' do
            shipment1 =  FactoryBot.create(:dc_shipment)
            shipment2 =  FactoryBot.create(:customer_shipment)
            po1 =  FactoryBot.create(:farmer_purchase_order)
            po2 =  FactoryBot.create(:farmer_purchase_order)
            trip = FactoryBot.build(:trip)

            post "/trips.json", params: {
                trip: {
                    driver_details_json: trip.driver_details_json,
                    vehicle_details_json: trip.vehicle_details_json,
                    vehicle_tonnage_max: trip.vehicle_tonnage_max,
                    transportation_cost_in_rs: trip.transportation_cost_in_rs,
                    delivery_order_shipment_ids: [shipment1.id, shipment2.id],
                    pickup_order_pickup_ids: [po1.id, po2.id]
                }
            }
            
            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)
            
            expect(response_parsed['vehicle_tonnage_max']).to eq(trip.vehicle_tonnage_max)
            expect(response_parsed['driver_details_json']).to eq(trip.driver_details_json)
            expect(response_parsed['vehicle_details_json']).to eq(trip.vehicle_details_json)
            expect(response_parsed['transportation_cost_in_rs']).to eq(trip.transportation_cost_in_rs)
            expect(response_parsed['pickup_order_pickup_ids']).to eq([po1.id, po2.id])
            expect(response_parsed['delivery_order_shipment_ids']).to eq([shipment1.id, shipment2.id])
        end

        it 'list trips' do
            get "/trips.json"

            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)
            expect(response_parsed["items"].count).to eq(Trip.count)
        end

        it 'update trip' do 
            shipment1 =  FactoryBot.create(:dc_shipment)
            shipment2 =  FactoryBot.create(:customer_shipment)
            po1 =  FactoryBot.create(:farmer_purchase_order)
            po2 =  FactoryBot.create(:farmer_purchase_order)            
            trip = FactoryBot.build(:trip)

            path = "/trips/" + @newTrip.id.to_s + ".json"

            put path, params: {
                trip: {
                    driver_details_json: trip.driver_details_json,
                    vehicle_details_json: trip.vehicle_details_json,
                    vehicle_tonnage_max: trip.vehicle_tonnage_max,
                    transportation_cost_in_rs: trip.transportation_cost_in_rs,
                    delivery_order_shipment_ids: [shipment1.id, shipment2.id],
                    pickup_order_pickup_ids: [po1.id, po2.id]
                }
            }

            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)

            expect(response_parsed['vehicle_tonnage_max']).to eq(trip.vehicle_tonnage_max)
            expect(response_parsed['driver_details_json']).to eq(trip.driver_details_json)
            expect(response_parsed['vehicle_details_json']).to eq(trip.vehicle_details_json)
            expect(response_parsed['transportation_cost_in_rs']).to eq(trip.transportation_cost_in_rs)
            expect(response_parsed['pickup_order_pickup_ids']).to eq([po1.id, po2.id])
            expect(response_parsed['delivery_order_shipment_ids']).to eq([shipment1.id, shipment2.id])
      
        end
    end
end