# == Schema Information
#
# Table name: shipments
#
#  id             :bigint           not null, primary key
#  instructions   :text(65535)
#  identifier     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  delivery_order :integer
#  pickup_id      :bigint
#  delivery_id    :bigint
#  sender_id      :integer
#  sender_type    :string(255)
#  recipient_id   :integer
#  recipient_type :string(255)
#
require 'rails_helper'

RSpec.describe Shipment, type: :model do
  context 'factory validation tests' do
    it "has a valid factory" do
      expect(FactoryBot.build(:farm_to_dc_shipment)).to be_valid
      expect(FactoryBot.build(:direct_po_to_dc_shipment)).to be_valid
      expect(FactoryBot.build(:farm_to_cso_shipment)).to be_valid
      expect(FactoryBot.build(:dc_to_dc_shipment)).to be_valid
      expect(FactoryBot.build(:dc_to_so_shipment)).to be_valid
    end

    it 'shipment with out dc and customer is not valid' do
      expect(FactoryBot.build(:shipment)).to_not be_valid
    end
    it 'direct_po_to_dc_shipment factory does not have a trip' do
      shipment = create :direct_po_to_dc_shipment
      expect(shipment.delivery.trip).to eq(nil)
    end
  end

  context "association tests" do
    it { should belong_to(:sender).optional }
    it { should belong_to(:recipient).optional }
    it { should belong_to(:pickup).optional }
    it { should belong_to(:delivery).optional }

    it { should have_many(:shipment_items) }
    it { should have_many(:lots) }
    it { should have_many(:dc_lots) }
    it { should have_many(:harvest_shipments) }
    it { should have_many(:harvests) }
  end

  context "scope test" do
    it "validate scope" do
      s1 = create(:cso_to_dc_shipment)
      s2 = create(:cso_to_cso_shipment)
      s3 = create(:dc_to_dc_shipment)
      s4 = create(:farm_to_cso_shipment)
      dc_id = s3.sender_id

      expect(Shipment.cdc_transfer_orders).to eq([s2,s1])
      expect(Shipment.non_cdc_transfer_orders(dc_id)).to eq([s3])
      expect(Shipment.of_type_PO).to include(s4)
      expect(Shipment.of_type_TO).to eq([s1,s2,s3])
      expect(Shipment.trip_to_be_associated).to include(s1,s2,s3,s4)

      trip = create(:trip)
      delivery = create :delivery, trip: trip
      pickup = create :pickup, trip: trip
      s4.update!(pickup_id: pickup.id, delivery_id: delivery.id)
      expect(Shipment.yet_to_be_dispatched).to eq([s4])

      s4.pickup.update!(vehicle_dispatch_time: DateTime.now)
      s4.delivery.update!(status: 'arrived')
      expect(Shipment.delivery_not_completed).to eq([s4])
      expect(Shipment.in_transit).to eq([s4])

      s4.delivery.update!(vehicle_arrival_time: DateTime.now, status: 'unloaded')
      expect(Shipment.unloaded).to eq([s4])
      expect(Shipment.non_quality_report_shipments).to include(s1,s2,s3,s4)
      qr = create(:quality_report)
      s5 = qr.shipment
      expect(Shipment.quality_report_shipments).to eq([s5])
      expect(Shipment.of_trip_ids([s4.trip.id])).to eq([s4])
      expect(Shipment.of_shipment_ids([s1.id])).to eq([s1])
      expect(Shipment.of_search(s4.trip.trip_meta_infos.first.driver_details_json['name'])).to eq([s4])
    end
  end

  context "[Transfer Pricing] Scope Tests" do
    let(:t_o) { create(:transfer_order_shipment) }
    it ".tp_source_dc_id(dc_id)" do
      sender_dc_id = t_o.sender_id
      expect(Shipment.tp_source_dc_id(sender_dc_id)).to eq([t_o])
    end

    it ".tp_destination_dc_id(dc_id)" do
      shipments = Shipment.joins("INNER JOIN material_orders ON material_orders.id = shipments.recipient_id")
      recipient_dc_id = t_o.recipient.dc_id
      expect(shipments.tp_destination_dc_id(recipient_dc_id)).to eq([t_o])
    end

    it ".tp_add_prices(dc_ids)" do
      shipments = Shipment.joins("LEFT OUTER JOIN transfer_pricings ON shipments.id = transfer_pricings.shipment_id")
                  .joins('INNER JOIN material_orders ON material_orders.id = shipments.recipient_id')
      sender_dc_id = t_o.sender_id
      expect(shipments.tp_add_prices(sender_dc_id)).to eq([t_o])
    end

    let(:transfer_pricing) { create(:transfer_pricing, attributes_for(:transfer_pricing).merge(shipment_id: t_o.id))}

    it ".tp_type(tp_type)" do
      transfer_pricing.reload
      shipments = Shipment.joins("LEFT OUTER JOIN transfer_pricings ON shipments.id = transfer_pricings.shipment_id")
      expect(shipments.tp_type(TransferPricing::TransferType::FIXED)).to eq([t_o])
      expect(shipments.tp_type(TransferPricing::TransferType::COMMISSION)).to_not eq([t_o])
    end

    it ".tp_date_filter(date)" do
      mo = t_o.recipient
      mo.loading_time = Time.now
      mo.save!
      pickup = t_o.pickup
      pickup.vehicle_dispatch_time = mo.loading_time
      pickup.save!
      
      shipments = Shipment.joins("LEFT OUTER JOIN transfer_pricings ON shipments.id = transfer_pricings.shipment_id")
                          .joins("INNER JOIN material_orders ON material_orders.id = shipments.recipient_id")
                          .joins(:pickup)

      expect(shipments.tp_date_filter(Date.today.strftime("%Y-%m-%d"))).to eq([t_o])
      expect(shipments.tp_date_filter((Date.today - 2.days).strftime("%Y-%m-%d"))).to_not eq([t_o])
    end

    it ".tp_pending_approvals(user_id, dc_ids)" do
      transfer_pricing.status = TransferPricing::Status::PENDING_APPROVAL
      transfer_pricing.save!
      recipient_dc_id = t_o.recipient.dc_id
      shipments = Shipment.joins("LEFT OUTER JOIN transfer_pricings ON shipments.id = transfer_pricings.shipment_id")
                          .joins("INNER JOIN material_orders ON material_orders.id = shipments.recipient_id")
      expect(shipments.tp_pending_approvals(1, recipient_dc_id)).to eq([t_o])
    end

    let(:shipment1) { create(:farm_to_dc_shipment_hyd_dc) }
    it ".tp_within_time_range(startdt, enddt)" do
      pickup = shipment1.pickup
      delivery = shipment1.delivery
      pickup.update_column(:vehicle_dispatch_time, 1.day.ago)
      delivery.update_column(:vehicle_arrival_time, Time.now)
      yesterday = 1.day.ago.strftime("%Y-%m-%d").in_time_zone('Chennai')
      today = Date.today.strftime("%Y-%m-%d").in_time_zone('Chennai')
      two_days_ago = 2.day.ago.strftime("%Y-%m-%d").in_time_zone('Chennai')
      expect(Shipment.joins(:pickup, :delivery).tp_within_time_range(yesterday, today)).to include(shipment1)
      expect(Shipment.joins(:pickup, :delivery).tp_within_time_range(two_days_ago, two_days_ago)).not_to include(shipment1)
    end

    let(:setter) { create(:user) }

    it ".tp_rejected(user_id)" do
      transfer_pricing.status = TransferPricing::Status::REJECTED
      transfer_pricing.setter_id = setter.id
      transfer_pricing.save!
      shipments = Shipment.joins("LEFT OUTER JOIN transfer_pricings ON shipments.id = transfer_pricings.shipment_id")
                          .joins("INNER JOIN material_orders ON material_orders.id = shipments.recipient_id")
      expect(shipments.tp_rejected(setter.id)).to eq([t_o])
    end

    it ".tp_approved(dc_ids)" do
      transfer_pricing.status = TransferPricing::Status::APPROVED
      transfer_pricing.save!
      sender_dc_id = t_o.sender_id
      shipments = Shipment.joins("LEFT OUTER JOIN transfer_pricings ON shipments.id = transfer_pricings.shipment_id")
                          .joins("INNER JOIN material_orders ON material_orders.id = shipments.recipient_id")
      expect(shipments.tp_approved(sender_dc_id)).to eq([t_o])
    end
  end

  context "Callback test" do
    it "after_update: update_sale_order_status" do
      sale_order = create(:central_sale_order)
      soi = create :soi_pomo, sale_order: sale_order
      material_order = sale_order.material_order
      shipment = create :farm_to_cso_shipment, recipient: material_order
      expect(sale_order.status).to eq(SaleOrder::Status::YET_TO_ALLOT)

      pickup = create(:pickup)
      shipment.update!(pickup_id: pickup.id)

      expect(sale_order.is_dispatched?).to eq(true)

      shipment.update!(pickup_id: nil)
      expect(sale_order.status).to eq(SaleOrder::Status::YET_TO_ALLOT)
    end
  end

  context "model methods test" do
    it "validate recipient_address for recipient material order shipments in case of central sale order" do
      shipment = create(:farm_to_cso_shipment)
      sale_order = shipment.recipient.sale_order
      sale_order.reload
      material_order = sale_order.material_order
      shipment.recipient = material_order
      expect(shipment.recipient_address).to eq(sale_order.customer_location.location.full_address)
    end

    it "validate recipient_address for recipient material order shipments in case of transfer order" do
      shipment = create(:dc_to_dc_shipment)
      material_order = create(:material_order)
      shipment.recipient = material_order
      expect(shipment.recipient_address).to eq(material_order.dc.location.full_address)
    end

    it "validates delivery_type" do
      expect(FactoryBot.build(:farm_to_dc_shipment).delivery_type).to eq("Dc")
      expect(FactoryBot.build(:farm_to_cso_shipment).delivery_type).to eq("Customer")
      expect(FactoryBot.build(:dc_to_dc_shipment).delivery_type).to eq("Dc")
      expect(FactoryBot.build(:dc_to_so_shipment).delivery_type).to eq("Customer")
      expect(FactoryBot.build(:cso_to_dc_shipment).delivery_type).to eq("Dc")
      expect(FactoryBot.build(:cso_to_cso_shipment).delivery_type).to eq("Customer")
    end

    it "validates recipient_key_id and recipient_key_type" do
      shipment = create(:dc_to_dc_shipment)
      material_order = create(:material_order)
      shipment.recipient = material_order
      expect(shipment.recipient_key_id).to eq(material_order.dc_id)
      expect(shipment.recipient_key_type).to eq("Dc")

      shipment2 = create(:farm_to_cso_shipment)
      cso = shipment2.recipient.sale_order
      material_order2 = cso.material_order

      expect(shipment2.recipient_key_id).to eq(material_order2.id)
      expect(shipment2.recipient_key_type).to eq("MaterialOrder")
    end

    it "validates sender address and name" do
      shipment = create(:cso_to_dc_shipment)
      sender_id = shipment.sender_id
      expect(shipment.sender_address).to eq("Bangalore")
      expect(shipment.sender_name).to eq("#{shipment.sender.customer.name} (SO-#{sender_id})" )
    end

    it "create and update transfer order" do
      dc1 = create(:dc)
      dc2 = create(:dc)
      sku = create :sku_pomo
      shipment_params = {recipient_id: dc2.id, recipient_type: "Dc"}
      material_order_params = {dc_id: dc2.id, loading_time: DateTime.now, expected_delivery_time: DateTime.now + 6.hours}
      moi_params = [{ordered_weight: 100, average_weight: 10, sku_id: sku.id}]
      sender_id = dc1.id
      user = create(:admin_user)
      shipment = Shipment.create_transfer_order(shipment_params, material_order_params, user.id, sender_id, moi_params)

      expect(shipment.allotted_lot_ids.count).to eq(0)
      expect(shipment.recipient.child_mos.count).to eq(0)
      expect(shipment.recipient.is_child_mo?).to eq(true)
      expect(shipment.recipient.material_order_items.count).to eq(1)
      expect(shipment.recipient.material_order_items.first.is_parent_material_order_item?).to eq(false)
      expect(shipment.recipient.material_order_items.first.sku_id).to eq(sku.id)
      expect(shipment.recipient.material_order_items.first.ordered_weight).to eq(100)
      expect(shipment.recipient.material_order_items.first.average_weight).to eq(10)
      expect(shipment.recipient.dc_id).to eq(dc2.id)

      #update TO
      dc3 = create(:dc)
      sku2 = create :sku_kinnow_72
      shipment_update_params = {recipient_id: dc3.id, recipient_type: "Dc"}
      material_order_update_params = {dc_id: dc3.id, loading_time: DateTime.now + 1.hours, expected_delivery_time: DateTime.now + 7.hours}
      moi_update_params = [{ordered_weight: 120, average_weight: 12, sku_id: sku2.id}]

      shipment.update_transfer_order(shipment_update_params, material_order_update_params, user.id, sender_id, moi_update_params)

      expect(shipment.recipient.material_order_items.count).to eq(1)
      expect(shipment.recipient.material_order_items.first.sku_id).to eq(sku2.id)
      expect(shipment.recipient.material_order_items.first.ordered_weight).to eq(120)
      expect(shipment.recipient.material_order_items.first.average_weight).to eq(12)
      expect(shipment.recipient.dc_id).to eq(dc3.id)
    end

    it "handle recipient change" do
      trip1 = create(:trip)

      dc1 = create(:dc)
      del1 = create :delivery, trip: trip1
      pickup1 = create :pickup, trip: trip1
      shipment1 = create :dc_to_dc_shipment, delivery: del1, pickup: pickup1

      del2 = create :delivery, trip: trip1
      pickup2 = create :pickup, trip: trip1
      shipment2 = create :farm_to_cso_shipment, delivery: del2, pickup: pickup2

      expect { shipment1.handle_delivery }.to raise_error
    end

    it "quality report" do
      sqr = create(:source_quality_report)
      s1 = sqr.shipment
      expect(s1.quality_report(true)).to eq(sqr)
      expect(s1.quality_report(false)).to eq(nil)
      pqr = create(:product_quality_report)
      s2 = pqr.shipment
      expect(s2.quality_report(false)).to eq(pqr)
      expect(s2.quality_report(true)).to eq(nil)
    end

    it "destroy transfer order MO" do
      shipment = create :dc_to_dc_shipment

      child_mo = shipment.recipient
      child_mois = shipment.recipient.material_order_items
      pmo = shipment.recipient.parent_material_order
      pmois = shipment.recipient.parent_material_order.material_order_items

      expect(child_mo.present?).to eq(true)
      expect(child_mo.is_child_mo?).to eq(true)
      expect(child_mois.count).to eq(1)
      expect(pmo.present?).to eq(true)
      expect( pmois.count).to eq(1)

      Shipment.transaction do
        shipment.destroy!
        shipment.destroy_transfer_order_MO
      end

      expect { MaterialOrder.find(child_mo.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(child_mois.count).to eq(0)
      expect { MaterialOrder.find(pmo.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect( pmois.count).to eq(0)
    end

    it "check_for_allotments" do
      shipment = create :dc_to_dc_shipment
      expect { shipment.check_for_allotments }.not_to raise_error
      lot = create :moi_lot, shipment: shipment, material_order_item: shipment.recipient.material_order_items.first
      shipment.reload
      expect { shipment.check_for_allotments }.to raise_error(RuntimeError, "Shipment has lots allotted. Remove them and try again.")
    end
  end

  context "TO status count test" do
    before do  
      sour_dc = create(:dc)
      dest_dc = create(:dc)
      user = create(:admin_user)
      sender_id = sour_dc.id
      shipment_params = {recipient_id: dest_dc.id, recipient_type: "Dc"}
      material_order_params = {dc_id: dest_dc.id, loading_time: DateTime.now, expected_delivery_time: DateTime.now}

      @lot = create(:dc_lot)
      @pickup = create(:pickup)
      @delivery = create(:delivery)
      @shipment = Shipment.create_transfer_order(shipment_params, material_order_params,  user.id, sender_id, {})

      @pending = Shipment.transfer_order_page_filters({transfer_order_status:"pending"})
      @allotted = Shipment.transfer_order_page_filters({transfer_order_status:"allotted"})
      @shipped = Shipment.transfer_order_page_filters({transfer_order_status:"shipped"})
      @delivered = Shipment.transfer_order_page_filters({transfer_order_status:"delivered"})
      @all = Shipment.transfer_order_page_filters({transfer_order_status:"random"})
    end  
    it "::pending status count" do
      expect(@pending.count).to eq(1)
      expect(@allotted.count).to eq(0)
      expect(@shipped.count).to eq(0)
      expect(@delivered.count).to eq(0)
      expect(@all.count).to eq(1)
    end
    it "::allotted status count" do
      @lot.shipment = @shipment
      @lot.save!
      expect(@pending.count).to eq(0)
      expect(@allotted.count).to eq(1)
      expect(@shipped.count).to eq(0)
      expect(@delivered.count).to eq(0)
      expect(@all.count).to eq(1)
    end
    it "::delivered status count" do
      @lot.shipment = @shipment
      @lot.save!
      @shipment.update!(pickup_id: @pickup.id, delivery_id: @delivery.id)
      @shipment.pickup.update!(vehicle_dispatch_time: DateTime.now)
      @shipment.delivery.update!(vehicle_arrival_time: DateTime.now, status: Delivery::Status::UNLOADED)
      expect(@pending.count).to eq(0)
      expect(@allotted.count).to eq(0)
      expect(@shipped.count).to eq(0)
      expect(@delivered.count).to eq(1)
      expect(@all.count).to eq(1)
    end
    it "::shipped status count" do
      @lot.shipment = @shipment
      @lot.save!
      @shipment.update!(pickup_id: @pickup.id, delivery_id: @delivery.id)
      @shipment.pickup.update!(vehicle_dispatch_time: DateTime.now)
      @shipment.delivery.update!(vehicle_arrival_time: nil)
      expect(@pending.count).to eq(0)
      expect(@allotted.count).to eq(0)
      expect(@shipped.count).to eq(1)
      expect(@delivered.count).to eq(0)
      expect(@all.count).to eq(1)
  end
end

end
