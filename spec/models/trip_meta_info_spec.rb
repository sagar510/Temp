# == Schema Information
#
# Table name: trip_meta_infos
#
#  id                        :bigint           not null, primary key
#  trip_id                   :bigint           not null
#  partner_id                :bigint
#  driver_details_json       :json
#  vehicle_details_json      :json
#  transportation_cost_in_rs :decimal(10, )
#  tracking_details_json     :json
#  trip_order                :integer
#  is_tracking_enabled       :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  vehicle_tonnage_max       :float(24)
#
require 'rails_helper'

RSpec.describe TripMetaInfo, type: :model do

  context "valid factory test" do 
    it { expect(create(:trip_meta_info)).to be_valid }
  end

  let(:trip_meta_info) { create(:trip_meta_info) }

  let(:trip_meta_info_with_shipments) {  
            trip_with_shipments = create(:trip_with_shipments)
            trip_meta_info = create :trip_meta_info, trip: trip_with_shipments
            return trip_meta_info}

  let(:partner_1) { create(:transporter_with_kyc_and_bank_detail) }
  let(:partner_2) { create(:transporter_with_kyc_and_bank_detail) }
  let(:trip) { create(:trip_with_shipments) }
  let(:trip_meta_infos) {
            meta_info_params = [{
                "partner_id": partner_1.id,
                "driver_details_json": {
                    "name": "Captain Jack Sparrow",
                    "phone": "9999999999"
                },
                "transportation_cost_in_rs": 1000,
                "is_tracking_enabled": false,
                "trip_order": 1,
                "vehicle_details_json": {
                    "type": "Sedan",
                    "number": "Ford Mustang"
                }
              },
              {
                "partner_id": partner_2.id,
                "driver_details_json": {
                    "name": "James Bond",
                    "phone": "9999999999"
                },
                "trip_order": 2,
                "transportation_cost_in_rs": 2000,
                "is_tracking_enabled": false,
                "vehicle_details_json": {
                    "type": "SuperCar",
                    "number": "Bugatti Chiron"
                }
              }]

            return TripMetaInfo.create_many!(meta_info_params, {trip_id: trip.id})}

  context 'ActiveRecord associations' do
    it { should belong_to(:trip) }
    it { should belong_to(:partner).optional }
  end

  context "model methods test" do
    it "create_many" do
      expect(trip_meta_infos.count).to eq(2)
      expect(trip_meta_infos.first.partner).to eq(partner_1)
      expect(trip_meta_infos.first.trip).to eq(trip)
      expect(trip_meta_infos.first.driver_details_json).to eq({"name"=>"Captain Jack Sparrow", "phone"=>"9999999999"})
      expect(trip_meta_infos.first.vehicle_details_json).to eq({"type"=>"Sedan", "number"=>"Ford Mustang"})
      expect(trip_meta_infos.first.trip_order).to eq(1)
      expect(trip_meta_infos.first.transportation_cost_in_rs).to eq(1000)
      expect(trip_meta_infos.first.is_tracking_enabled).to eq(false)

      expect(trip_meta_infos.second.partner).to eq(partner_2)
      expect(trip_meta_infos.second.trip).to eq(trip)
      expect(trip_meta_infos.second.driver_details_json).to eq({"name"=>"James Bond", "phone"=>"9999999999"})
      expect(trip_meta_infos.second.vehicle_details_json).to eq({"type"=>"SuperCar", "number"=>"Bugatti Chiron"})
      expect(trip_meta_infos.second.trip_order).to eq(2)
      expect(trip_meta_infos.second.transportation_cost_in_rs).to eq(2000)
      expect(trip_meta_infos.second.is_tracking_enabled).to eq(false)
    end

    it "update_many" do
      trip_meta_infos.first.driver_details_json = {"name"=>"Jack Sparrow", "phone"=>"9999999998"}
      trip_meta_infos.first.vehicle_details_json = {"type"=>"SUV", "number"=>"Mustang"}
      trip_meta_infos.first.transportation_cost_in_rs = 10000
      trip_meta_infos.first.trip_order = 3

      trip_meta_infos.second.driver_details_json = {"name"=>"Bond", "phone"=>"9999999997"}
      trip_meta_infos.second.vehicle_details_json = {"type"=>"Car", "number"=>"Chiron"}
      trip_meta_infos.second.transportation_cost_in_rs = 50000
      trip_meta_infos.second.trip_order = 4

      updated_trip_meta_infos = TripMetaInfo.update_many!(trip_meta_infos.as_json.map(&:symbolize_keys))

      expect(updated_trip_meta_infos.count).to eq(2)
      expect(updated_trip_meta_infos.first.partner).to eq(partner_1)
      expect(updated_trip_meta_infos.first.trip).to eq(trip)
      expect(updated_trip_meta_infos.first.driver_details_json).to eq({"name"=>"Jack Sparrow", "phone"=>"9999999998"})
      expect(updated_trip_meta_infos.first.vehicle_details_json).to eq({"type"=>"SUV", "number"=>"Mustang"})
      expect(updated_trip_meta_infos.first.trip_order).to eq(3)
      expect(updated_trip_meta_infos.first.transportation_cost_in_rs).to eq(10000)
      expect(updated_trip_meta_infos.first.is_tracking_enabled).to eq(false)

      expect(updated_trip_meta_infos.second.partner).to eq(partner_2)
      expect(updated_trip_meta_infos.second.trip).to eq(trip)
      expect(updated_trip_meta_infos.second.driver_details_json).to eq({"name"=>"Bond", "phone"=>"9999999997"})
      expect(updated_trip_meta_infos.second.vehicle_details_json).to eq({"type"=>"Car", "number"=>"Chiron"})
      expect(updated_trip_meta_infos.second.trip_order).to eq(4)
      expect(updated_trip_meta_infos.second.transportation_cost_in_rs).to eq(50000)
      expect(updated_trip_meta_infos.second.is_tracking_enabled).to eq(false)
    end

    it "update_or_create_many" do
      trip_meta_infos.first.driver_details_json = {"name"=>"Jack Sparrow", "phone"=>"9999999998"}
      trip_meta_infos.first.vehicle_details_json = {"type"=>"SUV", "number"=>"TX29AA0001"}
      trip_meta_infos.first.transportation_cost_in_rs = 10000
      trip_meta_infos.first.trip_order = 2

      trip_meta_infos.second.driver_details_json = {"name"=>"Bond", "phone"=>"9999999997"}
      trip_meta_infos.second.vehicle_details_json = {"type"=>"Car", "number"=>"TX29AA0002"}
      trip_meta_infos.second.transportation_cost_in_rs = 50000
      trip_meta_infos.second.trip_order = 1

      new_partner_1 = create(:transporter_with_kyc_and_bank_detail)
      new_partner_2 = create(:transporter_with_kyc_and_bank_detail)
      trip_meta_infos << {
                "partner_id": new_partner_1.id,
                "driver_details_json": {
                    "name": "Robert",
                    "phone": "9999999989"
                },
                "transportation_cost_in_rs": 1000,
                "is_tracking_enabled": false,
                "trip_order": 3,
                "vehicle_details_json": {
                    "type": "Sedan",
                    "number": "TX29AA0003"
                }
              }

      trip_meta_infos << {
                "partner_id": new_partner_2.id,
                "driver_details_json": {
                    "name": "Peter",
                    "phone": "9999999899"
                },
                "trip_order": 4,
                "transportation_cost_in_rs": 2000,
                "is_tracking_enabled": false,
                "vehicle_details_json": {
                    "type": "SuperCar",
                    "number": "TX29AA0004"
                }
              }

      updated_trip_meta_infos = TripMetaInfo.update_or_create_many!(trip_meta_infos.as_json.map(&:symbolize_keys), {trip_id: trip.id})

      expect(updated_trip_meta_infos.count).to eq(4)
      expect(updated_trip_meta_infos.first.partner).to eq(partner_1)
      expect(updated_trip_meta_infos.first.trip).to eq(trip)
      expect(updated_trip_meta_infos.first.driver_details_json).to eq({"name"=>"Jack Sparrow", "phone"=>"9999999998"})
      expect(updated_trip_meta_infos.first.vehicle_details_json).to eq({"type"=>"SUV", "number"=>"TX29AA0001"})
      expect(updated_trip_meta_infos.first.trip_order).to eq(2)
      expect(updated_trip_meta_infos.first.transportation_cost_in_rs).to eq(10000)
      expect(updated_trip_meta_infos.first.is_tracking_enabled).to eq(false)

      expect(updated_trip_meta_infos.second.partner).to eq(partner_2)
      expect(updated_trip_meta_infos.second.trip).to eq(trip)
      expect(updated_trip_meta_infos.second.driver_details_json).to eq({"name"=>"Bond", "phone"=>"9999999997"})
      expect(updated_trip_meta_infos.second.vehicle_details_json).to eq({"type"=>"Car", "number"=>"TX29AA0002"})
      expect(updated_trip_meta_infos.second.trip_order).to eq(1)
      expect(updated_trip_meta_infos.second.transportation_cost_in_rs).to eq(50000)
      expect(updated_trip_meta_infos.second.is_tracking_enabled).to eq(false)

      expect(updated_trip_meta_infos.third.partner).to eq(new_partner_1)
      expect(updated_trip_meta_infos.third.trip).to eq(trip)
      expect(updated_trip_meta_infos.third.driver_details_json).to eq({"name"=>"Robert", "phone"=>"9999999989"})
      expect(updated_trip_meta_infos.third.vehicle_details_json).to eq({"type"=>"Sedan", "number"=>"TX29AA0003"})
      expect(updated_trip_meta_infos.third.trip_order).to eq(3)
      expect(updated_trip_meta_infos.third.transportation_cost_in_rs).to eq(1000)
      expect(updated_trip_meta_infos.third.is_tracking_enabled).to eq(false)

      expect(updated_trip_meta_infos.fourth.partner).to eq(new_partner_2)
      expect(updated_trip_meta_infos.fourth.trip).to eq(trip)
      expect(updated_trip_meta_infos.fourth.driver_details_json).to eq({"name"=>"Peter", "phone"=>"9999999899"})
      expect(updated_trip_meta_infos.fourth.vehicle_details_json).to eq({"type"=>"SuperCar", "number"=>"TX29AA0004"})
      expect(updated_trip_meta_infos.fourth.trip_order).to eq(4)
      expect(updated_trip_meta_infos.fourth.transportation_cost_in_rs).to eq(2000)
      expect(updated_trip_meta_infos.fourth.is_tracking_enabled).to eq(false)
    end

    it "tracking_status" do
      expect(trip_meta_info.tracking_status).to eq(TripMetaInfo::TrackingStatus::DISABLED)
    end
  end

  context "Callback Tests" do
    it "set_intugene_tracker" do
      trip_meta_info_with_shipments.tracking_details_json
      x = create :trip_with_shipments
      expect(trip_meta_info_with_shipments.tracking_details_json).to eq({})
      
    end
  end

  describe "Validation Tests" do
    # Basic validations
    it { should validate_numericality_of(:vehicle_tonnage_max).is_greater_than_or_equal_to(0).allow_nil }
    # Custom Validations
    it "driver_phone_number_should_be_valid_when_tracking_enabled" do
      trip_meta_info.is_tracking_enabled = true
      trip_meta_info.driver_details_json = {
            "name": "Captain Jack Sparrow",
            "phone": "Invalid Number"
        }
      expect{trip_meta_info.save!}.to raise_error
    end
    it "validate_presence_of_payment_request" do
      bill_trip_payment_request = create(:bill_trip_payment_request)
      trip_meta_info = bill_trip_payment_request.trip.trip_meta_infos.first
      trip_meta_info.partner_id = partner_2.id
      expect{trip_meta_info.save!}.to raise_error
    end
  end

  describe "Geofence Params Tests" do
    before do
      trip = create(:trip)
      trip_id = "test123abc"
      TripMetaInfo.insert(id: 1,
        trip_id: trip.id, 
        intugine_trip_id: trip_id, 
        created_at: DateTime.now(),
        updated_at: DateTime.now())
      @trip_meta_info = TripMetaInfo.where(intugine_trip_id:trip_id).first
      @geofence_params = { "tripId" => trip_id }  
    end 
    it "source in time" do
      @geofence_params["event"] = TripMetaInfo::GeofenceEvent::SOURCE_IN
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.source_in_time).to eq(nil)
      @geofence_params["time"] = DateTime.new(2022,8,11)  
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.source_in_time).to eq(@geofence_params["time"])
    end
    it "source out time" do
      @geofence_params["event"] = TripMetaInfo::GeofenceEvent::SOURCE_OUT
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.source_out_time).to eq(nil)
      @geofence_params["time"] = DateTime.new(2022,8,11)  
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.source_out_time).to eq(@geofence_params["time"])
    end
    it "dest in time" do
      @geofence_params["event"] = TripMetaInfo::GeofenceEvent::DESTINATION_IN
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.dest_in_time).to eq(nil)
      @geofence_params["time"] = DateTime.new(2022,8,11)  
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.dest_in_time).to eq(@geofence_params["time"])
    end   
    it "dest out time" do
      @geofence_params["event"] = TripMetaInfo::GeofenceEvent::DESTINATION_OUT
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.dest_out_time).to eq(nil)
      @geofence_params["time"] = DateTime.new(2022,8,11)  
      TripMetaInfo.update_geofence_params(@geofence_params)
      @trip_meta_info.reload
      expect(@trip_meta_info.dest_out_time).to eq(@geofence_params["time"])
    end         
  end  

end
