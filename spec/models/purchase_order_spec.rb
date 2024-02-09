# == Schema Information
#
# Table name: purchase_orders
#
#  id                    :bigint           not null, primary key
#  location_id           :bigint
#  partner_id            :bigint
#  service_provider_id   :bigint
#  services_details      :json
#  identifier            :string(255)
#  expected_harvest_date :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  purchase_order_type   :integer
#
require 'rails_helper'

RSpec.describe PurchaseOrder, type: :model do
  
  it "has a valid factory" do
    expect(create(:farmer_purchase_order)).to be_valid
    expect(create(:supplier_purchase_order)).to be_valid
  end

  let(:farmer_po) { create(:farmer_purchase_order) }
  let(:farmer_po_with_shipment) { create(:farmer_purchase_order_with_shipment) }
  let(:supplier_po) { create(:supplier_purchase_order) }
  let(:vendor_po) { create(:vendor_purchase_order) }
  let(:direct_po) { create(:direct_purchase_order) }
  let(:advance_po_payment_request) { create(:advance_po_payment_request) }
  let(:bill_po_payment_request) { create(:bill_po_payment_request) }

  context 'validation tests' do
    it 'has a valid expected_harvest_date' do
      farmer_po.expected_harvest_date = nil
      expect(farmer_po.save).to eq(false)
    end

    it 'should have only farmer or supplier as partner' do
      expect(farmer_po.farmer_purchase_order?).to eq(true)

      farmer_po.partner = create(:service_provider)
      expect(farmer_po.save).to eq(false)

      farmer_po.partner = create(:supplier)
      expect(farmer_po.save).to eq(true)
      expect(farmer_po.supplier_purchase_order?).to eq(true)
    end
    
    it 'validate presence of payment request' do 
      po = create :farmer_purchase_order
      pr = create :advance_po_payment_request, purchase_order: po
      user = create :buyer_approver_user
      pr.update(status: PaymentRequest::Status::APPROVED, approver_id: user.id, approved_date: Date.today)
      po.reload
      po.update(partner: create(:farmer))
      expect(po.errors[:base]).to include("Can not update supplier as a payment request have been approved.")
    end

    it "raises an error when expected_delivery_date is before transaction lock date" do
      farmer_po = create(:farmer_purchase_order)
      
      po_transaction_lock_date = create(:velynk_config, name: "PO_TRANSACTION_LOCK_DATE", data_type: VelynkConfig::DataType::DATETIME, value: DateTime.now)

      farmer_po.update(expected_harvest_date: po_transaction_lock_date.value - 1.day)
      expect(farmer_po).to_not be_valid
      expect(farmer_po.errors[:expected_harvest_date]).to include("cannot be before the transaction lock date")
    end

    it "inclusion of model in po" do
      farmer_po.update(model: "test")
      expect(farmer_po.errors[:model]).to include("is not included in the list")
    end

    it "Can not change po model" do
      farmer_po1 = create(:farmer_purchase_order, model: PurchaseOrder::Model::FIXED)
      expect { farmer_po1.update!(model: PurchaseOrder::Model::COMMISION) }.to raise_error(RuntimeError, "Can not change po model")
    end
  end

  context 'scope tests' do
    it 'have valid scopes' do
      po1 = create :farmer_purchase_order, expected_harvest_date: Date.today + 8.day
      po2 = create :farmer_purchase_order, expected_harvest_date: Date.today + 10.day
      shipment1 = create :farm_to_dc_loaded_shipment, sender: po1
      shipment2 = create :farm_to_cso_shipment, sender: po2
      purchase_item1 = create :pi_orange, purchase_order: po1
      purchase_item2 = create :pi_kinnow, purchase_order: po2
      product_ids = [purchase_item1.product_id]
      partner_ids = [po1.partner_id]
      buyer_ids  = [po1.purchase_order_users.of_role(Role.of_name(Role::Name::BUYER).first.id).first.user_id]
      fe_ids  = [po1.purchase_order_users.of_role(Role.of_name(Role::Name::FIELD_EXEC).first.id).first.user_id]
      after = Date.today + 9.day
      before = Date.today + 9.day
      dc_ids = [shipment1.recipient.dc_id]
      customer_ids = [shipment2.recipient.sale_order.customer_id]
      po3 = create :farmer_purchase_order
      expect(PurchaseOrder.of_no_payment_request).to eq([po1, po2, po3])
      pr1 = create :advance_po_payment_request, purchase_order: po3
      expect(PurchaseOrder.of_only_advance_payment_request).to eq([po3])
      pr2 = create :bill_po_payment_request, purchase_order: po1
      user1 = create :treasury_user
      user2 = create :buyer_approver_user
      user3 = create :finance_approver_user
      pr2.update!(status: PaymentRequest::Status::APPROVED, approver_id: user2.id, approved_date: Date.today)
      pr2.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: user3.id, finance_approved_date: Date.today)
      pr2.update!(status: PaymentRequest::Status::PAID, payer_id: user1.id, paid_date: Date.today,approver_id: user2.id, approved_date: Date.today)
      po2.reload
      expect(PurchaseOrder.of_bill_payment_request).to eq([po1])
      expect(PurchaseOrder.of_type(po1.purchase_order_type)).to include(po1)
      expect(PurchaseOrder.of_products(product_ids)).to eq([po1])
      expect(PurchaseOrder.of_partners(partner_ids)).to eq([po1])
      expect(PurchaseOrder.of_buyers(buyer_ids)).to eq([po1])
      expect(PurchaseOrder.of_field_executives(fe_ids)).to eq([po1])
      expect(PurchaseOrder.after(after)).to eq([po2])
      expect(PurchaseOrder.before(before)).to eq([po1, po3])
      expect(PurchaseOrder.of_dcs(dc_ids)).to eq([po1])
      expect(PurchaseOrder.of_customers(customer_ids)).to eq([po2])
      expect(PurchaseOrder.of_id(po1.id)).to eq([po1])
      expect(PurchaseOrder.of_no_paid_bill_pr).to include(po2)
      expect(PurchaseOrder.exclude(po1)).to eq([po2, po3])
    end
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:service_provider).without_validating_presence }
    it { should belong_to(:partner).without_validating_presence }
    it { should belong_to(:location).without_validating_presence }
    it { should belong_to(:micro_pocket).without_validating_presence }
    
    it { should have_many(:purchase_items).dependent(:destroy) }
    it { should have_many(:harvests).dependent(:destroy) }
    it { should have_many(:shipments).dependent(:destroy) }
    it { should have_many(:lots) }
    it { should have_many(:pickups) }
    it { should have_many(:trips) }
    it { should have_many(:purchase_order_users).dependent(:destroy) }
    it { should have_many(:users) }
    it { should have_many(:products) }
    it { should have_many(:product_categories) }
    it { should have_many(:payment_requests).dependent(:destroy) }
    it { should have_many(:source_material_trips) }
    it { should have_many(:destination_material_trips) }
    it { should have_many(:purchase_order_buyers) }
    it { should have_many(:buyers) }
  end

  context 'callback tests' do
    # Using only farmer_po for testing as it is very similar to partner_po for these tests.
    # We cannot use po directly as it does not have a partner and so validation will fail.
    it 'sets the location' do
      expect(farmer_po.location).to be_present
    end

    it 'update model to fruitxs if mandi' do 
      farmer_po.update!(for_mandi: true)
      expect(farmer_po.model).to eq(PurchaseOrder::Model::FRUITXS)
    end

    it 'initialize nil json fields' do 
      expect(farmer_po.services_details).to eq({})
    end


    it 'sets the identifier' do
      expect(farmer_po.identifier).to be_present
    end

    it 'creates a harvest' do
      expect(farmer_po.harvests.size).to eq(1)
    end

    it 'updates the harvest date on change of expected harvest date' do
      x = rand(1..5)
      farmer_po.expected_harvest_date = Date.today + x.day
      farmer_po.save
      expect(Harvest.of_purchase_order(farmer_po.id).first.harvest_date).to eq(Date.today + x.day)
    end

    it 'updates service provider roles' do
      farmer = create(:farmer)
      expect(farmer.service_provider?).to eq(false)

      vendor_po.service_provider = farmer
      vendor_po.save!
      expect(vendor_po.service_provider).to eq(farmer)
      expect(farmer.service_provider?).to eq(true)
    end
  end

  context "model methods test" do
    it "full_address" do
      expect(farmer_po.full_address).to eq('No.13, Ground floor, MCHS Sector-4, HSR layout, Bengaluru 560102')
    end
    it "expected_harvest_date_epoch" do
      expect(farmer_po.expected_harvest_date_epoch).to eq(farmer_po.expected_harvest_date.to_epoch)
    end
    it "po_delivery_id" do
      po = create(:farmer_purchase_order_with_loaded_shipment)
      expect(po.po_delivery_id).to eq(po.shipments[0].delivery.id)
    end
    it "purchase_item_id_auction_lot_id" do
      po = create(:farmer_purchase_order)
      po.purchase_items[0].auction_lot_id = Faker::Number.between(from: 1, to: 10)
      poi = po.purchase_items[0]
      expect(po.purchase_item_id_auction_lot_id).to eq([{:poi_id=>poi.id, :auction_lot_id=>poi.auction_lot_id}]) 
    end
    it "purchase_order_type_label" do
      expect(farmer_po.purchase_order_type_label).to eq('Farm Gate')
    end
    it "is_farm_gate_purchase?" do
      expect(farmer_po.is_farm_gate_purchase?).to eq(true)
    end
    it "is_vendor_purchase?" do 
      expect(vendor_po.is_vendor_purchase?).to eq(true)
    end
    it "is_direct_purchase?" do 
      expect(direct_po.is_direct_purchase?).to eq(true)
    end
    it "can_have_trip?" do
      expect(farmer_po.can_have_trip?).to eq(true)
    end
    it "total_value" do
      expect(farmer_po.total_value).to eq(1650)
    end
    it "shipments_delivery_locations" do
      expect(farmer_po_with_shipment.shipments_delivery_locations.to_a).to eq(['Devaryamjal, Shamirpet, Medchal, Telangana - 500078'])
    end
    it "shipment_ids" do
      shipment = create :farm_to_dc_shipment, sender: farmer_po
      farmer_po.shipments << [shipment]
      expect(farmer_po.shipment_ids).to eq([shipment.id])
    end
    it "purchase_item_ids" do 
      expect(farmer_po.purchase_item_ids).to eq([farmer_po.purchase_items[0].id])
    end
    it "harvest_ids" do
      expect(farmer_po.harvest_ids.present?).to eq(true)
      expect(vendor_po.harvest_ids.present?).to eq(false)
      expect(direct_po.harvest_ids.present?).to eq(false)
    end
    it "farm_address" do
      expect(farmer_po.farm_address).to eq('No.13, Ground floor, MCHS Sector-4, HSR layout, Bengaluru 560102')
    end
    it "payment_requests_count" do 
      pr = create :advance_po_payment_request, purchase_order: farmer_po, amount: 1000
      farmer_po.reload
      expect(farmer_po.payment_requests.count).to eq(1)
    end
    it "has_any_approved_payment_requests" do 
      pr = create :advance_po_payment_request, purchase_order: farmer_po, amount: 1000
      user = create :buyer_approver_user
      pr.update!(status: PaymentRequest::Status::APPROVED, approver_id: user.id, approved_date: Date.today)
      farmer_po.reload
      expect(farmer_po.has_any_approved_payment_requests?).to eq(true)
    end
    it "lots_total_weight" do 
      po = create(:farmer_purchase_order_with_loaded_shipment)
      expect(po.lots_total_weight).to eq(310)
    end
    it "trips" do 
      po = create(:farmer_purchase_order_with_loaded_shipment)
      expect(po.trips).to be_present
    end
    it "buyers" do
      expect(farmer_po.buyers.map(&:name)).to eq(['buyer'])
    end
    it "field_executives" do
      expect(farmer_po.field_executives.map(&:name)).to eq(['field executive'])
    end
    it "farmer_purchase_order" do
      expect(farmer_po.farmer_purchase_order?).to eq(true)
      expect(supplier_po.farmer_purchase_order?).to eq(false)
    end
    it "supplier_purchase_order" do
      expect(farmer_po.supplier_purchase_order?).to eq(false)
      expect(supplier_po.supplier_purchase_order?).to eq(true)
    end
    it "prefix" do
      expect(farmer_po.prefix).to eq("PO/F")
      expect(vendor_po.prefix).to eq("PO/V")
      expect(direct_po.prefix).to eq("PO/D")
    end
    it "po_money_paid" do 
      user1 = create :treasury_user
      user2 = create :buyer_approver_user
      user3 = create :finance_approver_user
      pr = create :advance_po_payment_request, purchase_order: farmer_po, amount: 1000
      pr.update!(status: PaymentRequest::Status::APPROVED, approver_id: user2.id, approved_date: Date.today)
      pr.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: user3.id, finance_approved_date: Date.today)
      pr.update!(status: PaymentRequest::Status::PAID, payer_id: user1.id, paid_date: Date.today)
      farmer_po.reload
      expect(farmer_po.po_money_paid).to eq(1000)
    end
    it "buy_value" do 
      po = create(:farmer_purchase_order_with_loaded_shipment)
      expect(po.buy_value).to eq(4650)
    end
    it "insert_into_purchase_order_users" do 
      user = create :buyer_user
      purchase_order_user_attrs = {
        "buyer_ids" => [user.id]
      }
      PurchaseOrder.new.insert_into_purchase_order_users(farmer_po, purchase_order_user_attrs)
      expect(farmer_po.buyers).to include(user)
    end
    it "create_with_purchase_order_user_association" do 
      user = create :buyer_user
      purchase_order_user_attrs = {
        "buyer_ids" => [user.id]
      }
      po_attrs = farmer_po.attributes.except("id")
      po = PurchaseOrder.create_with_purchase_order_user_association!(po_attrs, purchase_order_user_attrs)
      expect(po.buyers).to include(user)
    end
    it "create_with_purchase_order_user_association" do 
      user = create :buyer_user
      purchase_order_user_attrs = {
        "buyer_ids" => [user.id]
      }
      po_attrs = farmer_po.attributes.except("id")
      po = PurchaseOrder.create_with_purchase_order_user_association!(po_attrs, purchase_order_user_attrs)
      expect(po.purchase_order_users.count).to eq(1)
      expect(po.buyers).to include(user)
    end
    it "create_direct_po" do
      # Admin user is required to be created for material order
      admin_user = create(:admin_user)
      buyer_user_one = create(:buyer_user)
      buyer_user_two = create(:buyer_user)
      service_provider = create(:service_provider)
      field_executive_user_one = create(:field_executive_user)
      field_executive_user_two = create(:field_executive_user)
      supplier = create(:supplier)

      expected_harvest_date = DateTime.now + 10
      direct_po_params = {
        address: supplier.location.full_address,
        partner_id: supplier.id,
        service_provider_id: service_provider.id,
        expected_harvest_date: expected_harvest_date,
        services_details: {
          labour_cost_rs: 10,
          packaging_cost_rs: 2,
          commision_rs: 1
        }
      }

      purchase_order_user_params = {
        "buyer_ids"=> [buyer_user_one.id, buyer_user_two.id]
      }

      sku_pomo = create(:sku_pomo)
      packaging_item = create(:nfi_packaging_item)

      direct_po_item_params = [{
        weight_in_kgs: 1000,
        agreed_value: 100,
        product_id: sku_pomo.product.id,
        sku_id: sku_pomo.id,
        nfi_packaging_item_id: packaging_item.id,
        average_weight: 20
      },
      {
        weight_in_kgs: 500,
        agreed_value: 50,
        product_id: sku_pomo.product.id,
        sku_id: sku_pomo.id,
        nfi_packaging_item_id: packaging_item.id,
        average_weight: 15
      }]

      hyd_dc = create(:hyd_dc)

      direct_po_shipment_params = {
        dc_id: hyd_dc.id
      }

      purchase_order = PurchaseOrder.create_direct_po!(direct_po_params, purchase_order_user_params, direct_po_item_params, direct_po_shipment_params)

      expect(purchase_order.present?).to eq(true)
      expect(purchase_order.buyers).to eq([buyer_user_one, buyer_user_two])
      expect(purchase_order.partner).to eq(supplier)
      expect(purchase_order.service_provider).to eq(service_provider)
      expect(purchase_order.purchase_order_type).to eq(PurchaseOrder::PurchaseOrderType::Direct)
      expect(purchase_order.expected_harvest_date.to_date).to eq(expected_harvest_date.to_date)
      expect(purchase_order.services_details["labour_cost_rs"]).to eq(direct_po_params[:services_details][:labour_cost_rs])
      expect(purchase_order.services_details["packaging_cost_rs"]).to eq(direct_po_params[:services_details][:packaging_cost_rs])
      expect(purchase_order.services_details["commision_rs"]).to eq(direct_po_params[:services_details][:commision_rs])
      
      # Validate Shipment
      expect(purchase_order.shipments.count).to eq(1)
      shipment = purchase_order.shipments.first
      expect(shipment.sender_type).to eq(Shipment::SenderType::PURCHASEORDER)
      expect(shipment.sender).to eq(purchase_order)
      expect(shipment.recipient_type).to eq(Shipment::RecipientType::MATERIALORDER)
      expect(shipment.pickup_id).to eq(nil)
      recipient_dc = shipment.recipient.dc
      expect(recipient_dc).to eq(hyd_dc)

      # Validate Lots
      lots = shipment.lots
      expect(lots.count).to eq(2)
      expect(lots.first.initial_weight).to eq(1000)
      expect(lots.first.average_weight).to eq(20)
      expect(lots.first.agreed_value).to eq(100)
      expect(lots.first.sku_id).to eq(sku_pomo.id)
      expect(lots.second.initial_weight).to eq(500)
      expect(lots.second.average_weight).to eq(15)
      expect(lots.second.agreed_value).to eq(50)

      # Validate Delivery
      delivery = shipment.delivery
      expect(delivery.shipments.count).to eq(1)
      expect(delivery.dc).to eq(hyd_dc)
    end

    it "update_direct_po" do
      direct_purchase_order = direct_po
      purchase_items = direct_purchase_order.purchase_items

      expect(direct_purchase_order.present?).to eq(true)
      expect(direct_purchase_order.purchase_order_type).to eq(PurchaseOrder::PurchaseOrderType::Direct)
      expect(direct_purchase_order.services_details.keys.length).to eq(0)
      expect(direct_purchase_order.purchase_items.first.agreed_value).to eq(15.0)
      expect(direct_purchase_order.purchase_items.first.children_items.first.average_weight).to eq(20)
      expect(direct_purchase_order.purchase_items.first.average_weight).to eq(nil)
      expect(direct_purchase_order.purchase_items.first.product_id).to eq(purchase_items.first[:product_id])
      expect(direct_purchase_order.purchase_items.first.children_items.first.sku_id).to eq(purchase_items.first.children_items.first[:sku_id])
      expect(direct_purchase_order.purchase_items.first.sku_id).to eq(nil)
      expect(direct_purchase_order.purchase_items.first.weight_in_kgs).to eq(110)

      buyer_user_one = create(:buyer_user)
      buyer_user_two = create(:buyer_user)
      service_provider = create(:service_provider)
      field_executive_user_one = create(:field_executive_user)
      field_executive_user_two = create(:field_executive_user)
      supplier = create(:supplier)

      expected_harvest_date = DateTime.now + 10
      direct_po_params = {
        address: supplier.location.full_address,
        partner_id: supplier.id,
        service_provider_id: service_provider.id,
        expected_harvest_date: expected_harvest_date,
        services_details: {
          labour_cost_rs: 10,
          packaging_cost_rs: 2,
          commision_rs: 1
        }
      }

      purchase_order_user_params = {
        "buyer_ids"=> [buyer_user_one.id, buyer_user_two.id]
      }

      kinnow = create(:sku_kinnow_72)

      direct_po_item_edit_params = [{
        id: purchase_items.first[:id],
        agreed_value: 20,
        average_weight: 10,
        description: "",
        deviation_reason: nil,
        deviation_type: nil,
        nfi_packaging_item_id: purchase_items.first[:nfi_packaging_item_id],
        product_id: kinnow.product_id,
        sku_id: kinnow.id,
        target_buying_price: nil,
        weight_in_kgs: 100
      }]

      updated_direct_po = direct_po.update_direct_po!(direct_po_params, purchase_order_user_params, direct_po_item_edit_params)

      expect(updated_direct_po.present?).to eq(true)
      expect(updated_direct_po.buyers).to eq([buyer_user_one, buyer_user_two])
      expect(updated_direct_po.partner).to eq(supplier)
      expect(updated_direct_po.service_provider).to eq(service_provider)
      expect(updated_direct_po.purchase_order_type).to eq(PurchaseOrder::PurchaseOrderType::Direct)
      expect(updated_direct_po.expected_harvest_date.to_date).to eq(expected_harvest_date.to_date)
      expect(updated_direct_po.services_details["labour_cost_rs"]).to eq(direct_po_params[:services_details][:labour_cost_rs])
      expect(updated_direct_po.services_details["packaging_cost_rs"]).to eq(direct_po_params[:services_details][:packaging_cost_rs])
      expect(updated_direct_po.services_details["commision_rs"]).to eq(direct_po_params[:services_details][:commision_rs])
      expect(updated_direct_po.purchase_items.first.agreed_value).to eq(20)
      expect(updated_direct_po.purchase_items.first.children_items.first.average_weight).to eq(10)
      expect(updated_direct_po.purchase_items.first.average_weight).to eq(nil)
      expect(updated_direct_po.purchase_items.first.product_id).to eq(kinnow.product_id)
      expect(updated_direct_po.purchase_items.first.children_items.first.sku_id).to eq(kinnow.id)
      expect(updated_direct_po.purchase_items.first.sku_id).to eq(nil)
      expect(updated_direct_po.purchase_items.first.weight_in_kgs).to eq(100)
    end
  end

  context 'model methods test' do
    it "paid_advance_amount_sum" do
      po1 = create :farmer_purchase_order
      expect(po1.paid_advance_amount_sum.to_f).to equal(0.0)
      pr1 = create :advance_po_payment_request, purchase_order: po1
      user1 = create :treasury_user
      user2 = create :buyer_approver_user
      user3 = create :finance_approver_user
      expect(po1.paid_advance_amount_sum.to_f).to equal(0.0)
      pr1.update!(status: PaymentRequest::Status::APPROVED, approver_id: user2.id, approved_date: Date.today)
      expect(po1.paid_advance_amount_sum.to_f).to equal(0.0)
      pr1.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: user3.id, finance_approved_date: Date.today)
      expect(po1.paid_advance_amount_sum.to_f).to equal(0.0)
      pr1.update!(status: PaymentRequest::Status::PAID, payer_id: user1.id, paid_date: Date.today)
      expect(po1.paid_advance_amount_sum.to_f).to equal(1000.0)
      pr2 = create :advance_po_payment_request, purchase_order: po1
      pr2.update!(status: PaymentRequest::Status::APPROVED, approver_id: user2.id, approved_date: Date.today)
      pr2.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: user3.id, finance_approved_date: Date.today)
      pr2.update!(status: PaymentRequest::Status::PAID, payer_id: user1.id, paid_date: Date.today,approver_id: user2.id, approved_date: Date.today)
      expect(po1.paid_advance_amount_sum.to_f).to equal(2000.0)
      pr2 = create :advance_po_payment_request, purchase_order: po1
      pr2.update!(status: PaymentRequest::Status::REJECTED, rejector_id: user1.id, rejected_date: Date.today,approver_id: user2.id, approved_date: Date.today)
      expect(po1.paid_advance_amount_sum.to_f).to equal(2000.0)
    end

    it "outstanding_amount" do
      po1 = create :farmer_purchase_order_with_loaded_shipment
      expect(po1.outstanding_amount.to_f).to equal(4650.0)
      pr1 = create :advance_po_payment_request, purchase_order: po1, amount: 1000
      user1 = create :treasury_user
      user2 = create :buyer_approver_user
      user3 = create :finance_approver_user
      expect(po1.outstanding_amount.to_f).to equal(4650.0)
      pr1.update!(status: PaymentRequest::Status::APPROVED, approver_id: user2.id, approved_date: Date.today)
      expect(po1.outstanding_amount.to_f).to equal(4650.0)
      pr1.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: user3.id, finance_approved_date: Date.today)
      expect(po1.outstanding_amount.to_f).to equal(4650.0)
      pr1.update!(status: PaymentRequest::Status::PAID, payer_id: user1.id, paid_date: Date.today)
      po1.reload
      expect(po1.outstanding_amount.to_f).to equal(3650.0)
      pr2 = create :advance_po_payment_request, purchase_order: po1, amount: 1000
      pr2.update!(status: PaymentRequest::Status::REJECTED, rejector_id: user1.id, rejected_date: Date.today,approver_id: user2.id, approved_date: Date.today)
      expect(po1.outstanding_amount.to_f).to equal(3650.0)
      pr3 = create :advance_po_payment_request, purchase_order: po1, amount: 1000
      pr3.update!(status: PaymentRequest::Status::APPROVED, approver_id: user2.id, approved_date: Date.today)
      pr3.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: user3.id, finance_approved_date: Date.today)
      pr3.update!(status: PaymentRequest::Status::PAID, payer_id: user1.id, paid_date: Date.today,approver_id: user2.id, approved_date: Date.today)
      po1.reload
      expect(po1.outstanding_amount.to_f).to equal(2650.0)
    end

    it 'direct_po_shipment_received?' do
      direct_purchase_order = direct_po
      expect(direct_purchase_order.direct_po_shipment_received?).to eq(false)

      direct_purchase_order.shipments.first.delivery.update!(status: Delivery::Status::UNLOADED)

      expect(direct_purchase_order.direct_po_shipment_received?).to eq(true)
    end
  end
  describe "#update_commision_po_details" do
      let(:purchase_order) { create(:vendor_purchase_order) }

      context "when updating commision and discount" do
        it "updates commision_percent and discount_percent" do
          params = { commision_percent: 10, discount_percent: 5 }
          purchase_order.update_commision_po_details(params)
          purchase_order.reload

          expect(purchase_order.commision_percent).to eq(10)
          expect(purchase_order.discount_percent).to eq(5)
        end
      end

      context "when updating expenses" do
        it "creates purchase_order_expenses" do
          params = {
            expenses: [{ expense_type: "Type A", amount: 100 }, { expense_type: "Type B", amount: 200 }]
          }
          purchase_order.update_commision_po_details(params)
          purchase_order.reload

          expect(purchase_order.purchase_order_expenses.count).to eq(2)
        end
      end

      context "when updating status" do
        it "updates the status to 'Bill_generated'" do
          params = { commision_percent: 10, discount_percent: 5 }
          purchase_order.update_commision_po_details(params)
          purchase_order.reload

          expect(purchase_order.status).to eq("Bill_generated")
        end
      end

      context "when an exception is raised" do
        it "rolls back transaction and re-raises the error" do
          params = { commision_percent: 10, discount_percent: 5 }
          allow(purchase_order).to receive(:update!).and_raise(RuntimeError, "Custom error")

          expect {
            purchase_order.update_commision_po_details(params)
          }.to raise_error(RuntimeError, "Custom error")

          expect(purchase_order.reload.status).not_to eq("Bill_generated")
        end
      end
    end

end
