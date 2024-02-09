# == Schema Information
#
# Table name: deliveries
#
#  id                     :bigint           not null, primary key
#  trip_id                :bigint
#  vehicle_arrival_time   :datetime
#  vehicle_dispatch_time  :datetime
#  is_driver_present      :boolean
#  unloading_details_json :json
#  delivery_order         :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  comments               :text(65535)
#  gross_weight           :float(24)
#  tare_weight            :float(24)
#  status                 :string(255)
#  dc_id                  :bigint
#  expected_delivery_time :datetime
#  customer_amount        :decimal(12, 3)
# 
require 'rails_helper'

RSpec.describe Delivery, type: :model do

  context "valid factory test" do
    it { expect(create(:delivery)).to be_valid }
  end

  let(:farm_to_cso_shipment) { create(:farm_to_cso_shipment) }
  let(:trip) { create(:trip) }
  let(:farm_to_cso_shipment_delivery) { create(:delivery, dc: farm_to_cso_shipment.recipient.dc, trip: trip) }

  context "ActiveModel validations" do
    # Commented because the validation is also commented in model file
    # it "validate_lots" do
    #   lot = create(:dc_to_dc_shipment_lot)
    #   delivery = create :delivery, dc: lot.shipment.recipient.dc
    #   lot.shipment.delivery = delivery
    #   lot.update(quantity: 0)
    #   lot.shipment.save
    #   lot.save
    #   delivery.vehicle_arrival_time  = DateTime.now
    #   expect(delivery.save).to be_falsey
    #   expect(delivery.errors[:base]).to include("Transfer Order transit lot have to be a standard lot.")
    # end

    it "valid_status" do
      delivery = farm_to_cso_shipment_delivery
      delivery.status = Delivery::Status::COMPLETED

      expect(delivery.save).to be_falsey
      expect(delivery.errors[:base]).to include("Please unload the delivery before marking it Complete.")
    end
  end

  context "scope test" do
    it "validate scope" do
      shipment = create(:farm_to_cso_shipment)
      shipment_item = create :si_pomo, shipment: shipment, purchase_order: shipment.sender
      trip = create(:trip)
      delivery = create :delivery, dc: shipment.recipient.dc, trip: trip
      s2 = create(:farm_to_cso_shipment)
      shipment.update(delivery_id: delivery.id, delivery_order: 1)
      delivery.update!(vehicle_arrival_time: DateTime.now)
      expect(Delivery.arrival_date(DateTime.now.to_date)).to eq([delivery])
      expect(Delivery.of_search(trip.driver_details_json.first['name'])).to eq([delivery])
      expect(Delivery.of_trip_ids(trip.id)).to eq([delivery])
      expect(Delivery.of_purchase_order(shipment.sender_id)).to eq([delivery])
      expect(Delivery.of_purchase_order_model(PurchaseOrder::Model::COMMISION)).to eq([delivery])
      shipment2 = create(:farm_to_cso_shipment)
      shipment_item2 = create :si_pomo, shipment: shipment2, purchase_order: shipment2.sender
      trip2 = create(:no_vehicle_trip)
      delivery2 = create :delivery, dc: shipment2.recipient.dc, trip: trip2
      expect { delivery2.update_with_bill_pr({customer_amount: 100}) }.to raise_error(RuntimeError, "Cannot add Paid by Customer amount for No Vehicle involved Trip")
    end

    describe '.of_in_transit_status' do
      it 'returns deliveries with IN_TRANSIT status and nil vehicle arrival time' do
        in_transit_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::IN_TRANSIT, vehicle_arrival_time: nil)
        submitted_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::SUBMITTED, vehicle_arrival_time: Time.current)

        result = Delivery.of_in_transit_status

        expect(result).to include(in_transit_delivery)
        expect(result).not_to include(submitted_delivery)
      end
    end

    describe '.of_driver_submission_status' do
      it 'returns deliveries with the specified driver submission status' do
        approved_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::APPROVED)
        rejected_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::REJECTED)
        submitted_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::SUBMITTED)

        result = Delivery.of_driver_submission_status(Delivery::DriverSubmissionStatus::APPROVED)

        expect(result).to include(approved_delivery)
        expect(result).not_to include(rejected_delivery, submitted_delivery)
      end
    end

    describe '.of_manually_submitted_status' do
      it 'returns deliveries with MANUALLY_SUBMITTED status and non-nil vehicle arrival time' do
        manually_submitted_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::MANUALLY_SUBMITTED, vehicle_arrival_time: Time.current)
        in_transit_delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::IN_TRANSIT, vehicle_arrival_time: nil)

        result = Delivery.of_manually_submitted_status

        expect(result).to include(manually_submitted_delivery)
        expect(result).not_to include(in_transit_delivery)
      end
    end

    describe '.of_dc_ids' do
      it 'returns deliveries belonging to specified dc_ids' do
        dc1 = create(:dc)
        dc2 = create(:dc)
        delivery1 = create(:delivery, dc: dc1)
        delivery2 = create(:delivery, dc: dc2)

        result = Delivery.of_dc_ids([dc1.id, dc2.id])

        expect(result).to include(delivery1, delivery2)
      end
    end
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:trip).optional }

    it { should have_many(:shipments) }
    it { should have_many(:lots) }
    it { should have_many(:dc_lots) }
    it { should belong_to(:driver_submission_processed_by).class_name('User').optional }
    it { should belong_to(:manual_submission_by).class_name('User').optional }
  end

  context "Function Validation" do
    it "direct_purchase_order" do
      shipment = create(:direct_po_to_dc_shipment)
      expect(shipment.delivery.direct_purchase_order).to eq(shipment.sender)
    end
  end

  context "Callback Validation" do
    it "when shipment is for cso the unloading should automatically be done while creating dc_lots" do
      shipment = create(:farm_to_cso_shipment)
      shipment_item = create :si_pomo, shipment: shipment, purchase_order: shipment.sender
      trip = create(:trip)
      delivery = create :delivery, dc: shipment.recipient.dc, trip: trip
      shipment.delivery = delivery
      shipment.save
      shipment.lots.first.update(quantity: 10, average_weight: 9)
      delivery.vehicle_arrival_time  = DateTime.now
      delivery.save
      sale_order = shipment.recipient.sale_order
      expect(delivery.dc_lots.count).to eq(delivery.lots.count)
      expect(delivery.dc_lots.first.quantity).to eq(delivery.lots.first.quantity)
      expect(delivery.dc_lots.first.description).to eq("Sale Order: #{sale_order.id}, Customer Name: #{sale_order.customer.name}")
      expect(delivery.dc_lots.first.quantity).to eq(10)
      expect(delivery.dc_lots.first.average_weight).to eq(9)
      expect(delivery.dc_lots.first.current_weight).to eq(90)
      expect(delivery.dc_lots.first.initial_weight).to eq(90)
      dc = create(:dc)
      expect {delivery.update!(dc_id: dc.id)}.to raise_error(ActsAsTenant::Errors::TenantIsImmutable)
    end
    it "check for vehicle dispatch at pickup" do
      shipment = create(:farm_to_cso_shipment)
      shipment_item = create :si_pomo, shipment: shipment, purchase_order: shipment.sender
      trip = create(:trip)
      pickup = create :pickup, trip: trip
      delivery = create :delivery, dc: shipment.recipient.dc, trip: trip
      delivery.shipments << shipment
      pickup.shipments << shipment
      expect { delivery.update_with_bill_pr({customer_amount: 0}) }.to raise_error(RuntimeError, "Please Dispatch vehicle before doing record arrival")
      pickup.update(vehicle_dispatch_time:  DateTime.now)
      delivery.update_with_bill_pr({customer_amount: 0})
      expect(delivery.customer_amount).to eq(0)
    end
  end

  context "model methods test" do
    it "has_trip_started?" do
      expect(farm_to_cso_shipment_delivery.has_trip_started?).to eq(farm_to_cso_shipment_delivery.trip.start_time.present?)
      farm_to_cso_shipment_delivery.trip = nil
      expect(farm_to_cso_shipment_delivery.has_trip_started?).to eq(true)
    end

    it 'blocks edits when driver submission is approved' do
      delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::APPROVED) 
      delivery.driver_submission_status = Delivery::DriverSubmissionStatus::SUBMITTED
      expect { delivery.save }.to raise_error(RuntimeError, "Cannot edit driver submission status after driver submission is approved")
    end

    it 'validates reject policies for rejected status' do
      delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::SUBMITTED) 
      delivery.driver_submission_status = Delivery::DriverSubmissionStatus::REJECTED
      expect { delivery.save! }.to raise_error(RuntimeError, "reject reason must be provided when rejected")
    end

    it 'validates approver role for approved/rejected status' do
      delivery = create(:delivery, driver_submission_status: Delivery::DriverSubmissionStatus::SUBMITTED) 
      delivery.driver_submission_status = Delivery::DriverSubmissionStatus::APPROVED
      delivery.operator = create(:user)
      expect { delivery.save! }.to raise_error(RuntimeError, "Only logistic manager can approve/reject!")
    end
  end

  context "Weighment slip deviation test" do
    before do
      shipment = create(:farm_to_cso_shipment)
      shipment_item = create :si_pomo, shipment: shipment, purchase_order: shipment.sender
      trip = create(:trip)
      @pickup = create :pickup, trip: trip
      @delivery = create :delivery, dc: shipment.recipient.dc, trip: trip
      @delivery.shipments << shipment
      @pickup.shipments << shipment
    end 
    it "no deviation" do
      @delivery.update({gross_weight:120,tare_weight:10})
      @pickup.update({gross_weight:120,tare_weight:10})
      expect(@delivery.calculate_weighment_slip_deviation).to eq([0,0])
    end   
    it "div by zero" do
      @delivery.update({gross_weight:120,tare_weight:10})
      @pickup.update({gross_weight:120,tare_weight:120})
      expect(@delivery.calculate_weighment_slip_deviation).to eq([0, -110])
    end 
    it "negative deviation" do
      @delivery.update({gross_weight:700,tare_weight:400})
      @pickup.update({gross_weight:1000,tare_weight:800})
      expect(@delivery.calculate_weighment_slip_deviation).to eq([-50, -100])
    end  
  end

  describe 'validations' do

    before do
      shipment = create(:farm_to_dc_shipment_hyd_dc)
      shipment_item = create :si_pomo, shipment: shipment, purchase_order: shipment.sender
      trip = create(:trip)
      @pickup = create :pickup, trip: trip
      @delivery = create :delivery, dc: shipment.recipient.dc, trip: trip
      @delivery.shipments << shipment
      @pickup.shipments << shipment
      @delivery.vehicle_arrival_time = Time.now
    end 

    context 'vehicle_arrival_time' do
      it 'must be greater than trip start time' do
        expect(@delivery.vehicle_arrival_time).to be > trip.start_time
      end

      it 'must be less than current time' do
        expect(@delivery.vehicle_arrival_time).to be <= Time.current
      end
    end
  
    it { should validate_inclusion_of(:driver_submission_status).in_array(Delivery::DriverSubmissionStatus.all) }
  end

  describe '#process_driver_submission' do
    it 'processes driver submission with status "APPROVED" for a central sale order' do
      shipment = create(:farm_to_dc_shipment_hyd_dc)
      shipment_item = create :si_pomo, shipment: shipment, purchase_order: shipment.sender
      trip = create(:trip)
      @pickup = create :pickup, trip: trip
      @delivery = create :delivery, dc: shipment.recipient.dc, trip: trip, driver_submission_status: Delivery::DriverSubmissionStatus::SUBMITTED
      @delivery.shipments << shipment
      @pickup.shipments << shipment
      @delivery.driver_vehicle_arrival_time = Time.current
      @delivery.save!
      @delivery.operator = create(:logistics_manager_user)
      process_driver_submission_params = { driver_submission_status: Delivery::DriverSubmissionStatus::APPROVED }
      @delivery.process_driver_submission(process_driver_submission_params)
      expect(@delivery.driver_submission_status).to eq(Delivery::DriverSubmissionStatus::APPROVED)
      expect(@delivery.driver_submission_processed_by_id).to eq(@delivery.operator.id)
      expect(@delivery.driver_submission_processed_at).not_to be_nil
    end
  end
end
