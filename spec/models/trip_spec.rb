# == Schema Information
#
# Table name: trips
#
#  id                          :bigint           not null, primary key
#  identifier                  :string(255)
#  driver_details_json         :json
#  vehicle_details_json        :json
#  is_tracking_enabled         :boolean
#  vehicle_tonnage_min         :float(24)
#  delivery_order_shipment_ids :string(255)
#  tracking_details_json       :json
#  transportation_cost_in_rs   :float(24)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  vehicle_tonnage_max         :float(24)
#  start_time                  :datetime
#  end_time                    :datetime
#  partner_id                  :bigint
#  source_id                   :integer
#  source_type                 :string(255)
#  destination_id              :integer
#  destination_type            :string(255)
#  purpose                     :string(255)
#  trip_type                   :integer
#
require 'rails_helper'

RSpec.describe Trip, type: :model do
  context "valid factory test" do 
    it { expect(create(:trip)).to be_valid }
    it { expect(create(:trip_with_advance_pr)).to be_valid }
    it { expect(create(:trip_with_advance_and_bill_pr)).to be_valid }
  end

  context "association tests" do
    it { should have_many(:pickups) }
    it { should have_many(:deliveries) }
    it { should have_many(:shipments) }
    it { should have_many(:lots) }
  end

  let(:trip) { create(:trip) }
  let(:trip_with_advance_pr) { create(:trip_with_advance_pr) }
  let(:trip_with_advance_and_bill_pr) { create(:trip_with_advance_and_bill_pr) }

  context 'validation tests' do
    it 'can_not_add_direct_po_shipments' do
      farm_to_dc_shipment = create :farm_to_dc_shipment
      trip.pickups = [farm_to_dc_shipment.pickup]
      trip.save!
      pickup = create :pickup
      direct_po_to_dc_shipment = create :direct_po_to_dc_shipment, pickup: pickup
      trip.pickups = [direct_po_to_dc_shipment.pickup]
      expect { trip.save! }.to raise_error
    end

    it "source_and_destination_should_be_present_for_material_trip" do
      trip = create :material_labour_trip
      trip.source_id = nil
      expect { trip.save! }.to raise_error
    end

    it "trip_cannot_be_deleted_after_ending_it" do
      trip = create :trip
      trip.end_time = DateTime.now
      expect { trip.destroy! }.to raise_error(RuntimeError, "Ended trips cannot be deleted.")
    end
  end

  context 'scope tests' do
    it 'scope test' do
      t1 = create :trip, start_time: nil
      #updating end_time to nil usinf update was throwing runtime exception so used update_columns same for below too.
      t1.update_columns(end_time: nil)
      t2 = create :trip
      t2.update_columns(end_time: nil)
      t3 = create :trip

      expect(Trip.not_dispatched).to eq([t1])
      expect(Trip.ongoing).to eq([t2])
      expect(Trip.ended).to eq([t3])

      trip1 = create(:trip)
      trip2 = create(:trip)

      del1 = create :delivery, trip: trip1
      del2 = create :delivery, trip: trip2
      pickup1 = create :pickup, trip: trip1
      pickup2 = create :pickup, trip: trip2

      shipment1 = create :dc_to_dc_shipment, delivery: del1, pickup: pickup1
      shipment2 = create :farm_to_cso_shipment, delivery: del2, pickup: pickup2

      lot1 = create :dc_to_dc_shipment_lot, shipment: shipment1, sku: create(:sku_pomo) 
      lot2 = create :harvest_lot, shipment: shipment2, sku: create(:sku_kinnow_72)
      
      product1 = lot1.product.id

      dc = shipment1.recipient.dc_id
      customer = shipment2.recipient.sale_order.customer_id

      expect(Trip.of_dcs_or_customers([dc], [])).to eq([trip1])
      expect(Trip.of_dcs_or_customers([], [customer])).to eq([trip2])
      expect(Trip.of_products(product1)).to eq([trip1])

      t4 = create :trip
      t5 = create :material_labour_trip
      expect(Trip.of_type(Trip::TripType::FRUIT)).to eq([t4,trip2,trip1,t3,t2,t1])
      expect(Trip.of_type(Trip::TripType::MATERIAL_LABOUR)).to eq([t5])

      pr_trip = create(:trip)
      pr_trips = Trip.where({id: pr_trip.id})
      expect(pr_trips.of_no_payment_request).to eq([pr_trip])
      trip_meta_info = create :trip_meta_info, trip: pr_trip
      pr1 = create :advance_trip_payment_request, trip: pr_trip, vendor: trip_meta_info.partner
      driver_phone = trip_meta_info.driver_details_json["phone"]
      vehicle_number = trip_meta_info.vehicle_details_json["number"]
      expect(Trip.search(driver_phone)).to eq([pr_trip])
      expect(Trip.search(vehicle_number.upcase)).to eq([pr_trip])
      expect(Trip.search(vehicle_number.downcase)).to eq([pr_trip])
      expect(Trip.of_only_advance_payment_request).to eq([pr_trip])
      expect(Trip.of_only_advance_payment_request.ended).to eq([pr_trip])
      pr2 = create :bill_trip_payment_request, trip: pr_trip, vendor: trip_meta_info.partner
      expect(Trip.of_bill_payment_request).to eq([pr_trip])
      expect(Trip.of_only_advance_payment_request).to eq([])
      expect(Trip.of_partners([trip_meta_info.partner_id])).to eq([pr_trip])
      trip_filter = create(:trip)
      pr3 = create :advance_trip_payment_request, trip: trip_filter, vendor: trip_meta_info.partner
      trip_filter.update_columns(end_time: nil)
      expect(Trip.of_only_advance_payment_request.ongoing).to eq([trip_filter])
      trip_filter.update_columns(start_time: nil)
      expect(Trip.of_only_advance_payment_request.not_dispatched).to eq([trip_filter])

    end
  end

  context "model methods test" do
    it "check for customer payment if trip category updated to No Vehicle" do
      trip = create(:trip)
      del = create :delivery_with_customer_amount, trip: trip
      pickup = create :pickup, trip: trip
      shipment = create :farm_to_cso_shipment, delivery: del, pickup: pickup
      lot = create :harvest_lot, shipment: shipment, sku: create(:sku_kinnow_72)
      customer = shipment.recipient.sale_order.customer_id
      trip.reload
      expect { trip.update_with_pickups_and_deliveries!({:trip_category => "4"})}.to raise_error
    end

    it "advance_amount_with_pr" do
      expect(trip.advance_amount_with_pr).to eq(0)
      expect(trip_with_advance_pr.advance_amount_with_pr).to eq(1000)
      expect(trip_with_advance_and_bill_pr.advance_amount_with_pr).to eq(10000)
    end
    it "total_transportation_cost_minus_advance" do
      expect(trip.total_transportation_cost_minus_advance).to eq(10000)
      expect(trip_with_advance_pr.total_transportation_cost_minus_advance).to eq(9000)
      expect(trip_with_advance_and_bill_pr.total_transportation_cost_minus_advance).to eq(300)
      expect(trip_with_advance_and_bill_pr.pr_inam_minus_adjusted_amount_plus_demurrage_amount).to eq(300)
    end
    it "final_transportation_cost_in_rs" do
      expect(trip.final_cost).to eq(10000)
      expect(trip_with_advance_and_bill_pr.final_cost).to eq(10300)
    end
    it "check_grn_for_so" do
      trip1 = create(:trip)

      del1 = create :delivery, trip: trip1
      pickup1 = create :pickup, trip: trip1

      shipment1 = create :farm_to_cso_shipment, delivery: del1, pickup: pickup1
      soi1 = create :soi_pomo, sale_order: shipment1.recipient.sale_order
      expect { trip1.check_grn_for_so }.not_to raise_error
      soi1.update!(grn_weight: 10)
      shipment1.recipient.sale_order.update(status: "GRN_Complete")
      trip1.shipments.first.recipient.sale_order.reload
      expect { trip1.check_grn_for_so }.to raise_error()
    end

    it "check_if_deliveries_arrived_at_destination" do
      trip1 = create(:unended_trip)
      expect { trip1.destroy }.not_to raise_error
      trip2 = create(:unended_trip)
      trip2.deliveries.first.update(vehicle_arrival_time: Faker::Date.forward(days: 2))
      trip2.reload
      expect { trip2.destroy }.to raise_error(RuntimeError, 'Trip cannot be deleted as the vehicle arrived at destination.')
    end
  end

end
