# == Schema Information
#
# Table name: sale_orders
#
#  id                     :bigint           not null, primary key
#  customer_id            :bigint           not null
#  dc_id                  :bigint           not null
#  user_id                :bigint           not null
#  order_created_time     :datetime
#  expected_delivery_time :datetime
#  dispatched_time        :datetime
#  comments               :text(65535)
#  discount               :float(24)
#  payment_mode           :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sale_type              :integer
#  zoho_invoice_id        :string(255)
#  bill_numbers           :string(255)
#  zoho_published         :boolean          default(FALSE)
#  void                   :boolean          default(FALSE)
#  patti                  :boolean          default(FALSE)
#  liquidation            :boolean          default(FALSE)
#  status                 :string(255)
#  customer_location_id   :bigint
#  invoice_id             :integer
#
require 'rails_helper'

RSpec.describe SaleOrder, type: :model do
  let(:so) { create(:direct_sale) }
  let(:cso) { create(:central_sale_order) }
  let(:sale_order) { create(:sale_order) }
  context 'factory validation tests' do
    it "direct sale has a valid factory" do
      expect(build(:direct_sale)).to be_valid
    end

    it "indirect sale has a valid factory" do
      expect(build(:indirect_sale)).to be_valid
    end

    it "central_sale_order has a valid factory" do
      expect(build(:central_sale_order)).to be_valid
    end

    it "has a valid factory" do
      # Using the shortened version of FactoryGirl syntax.
      # Add:  "config.include FactoryGirl::Syntax::Methods" (no quotes) to your spec_helper.rb
      expect(build(:so_one)).to be_valid
    end
  end

  context 'basic validations' do
    it { should validate_presence_of(:expected_delivery_time) }
  end

  context 'scope test' do
    it "scope tests" do
      dc_lot1 = create :dc_lot, current_weight: 50
      dc_lot2 = create :dc_lot, current_weight: 0, quantity: 0
      so1 = create(:central_sale_order)
      so2 = create(:central_sale_order)
      soi1 = create :soi_pomo, sale_order: so1, return_lot: dc_lot1
      soi2 = create :soi_pomo, sale_order: so2, return_lot: dc_lot2
      expect(SaleOrder.with_return_lots_in_inventory).to eq([so1])
    end
  end

  context 'scope tests' do
    it 'validate scopes' do
      dc = create :dc_cdc
      user1 = create(:sales_executive_user)
      user2 = create(:sales_executive_user)
      sku1 = create(:sku_pomo)
      sku2 = create(:sku_kinnow_72)
      product_id1 = sku1.product_id
      product_id2 = sku2.product_id
      customer1 = create(:customer_mt)
      customer2 = create(:customer_mt)
      after = Date.today + 8.day
      before = Date.today + 10.day
      so1 = create :indirect_sale, expected_delivery_time: Date.today + 8.day, user: user1, customer: customer1
      so2 = create :indirect_sale, expected_delivery_time: Date.today + 10.day, user: user2, customer: customer2, is_experiment: true, experiment_reason: "abc"
      soi1 = create :sale_order_item, sale_order: so1, sku: sku1
      soi2 = create :sale_order_item, sale_order: so2, sku: sku2
      expect(SaleOrder.of_products([product_id1])).to eq([so1])
      expect(SaleOrder.of_customers([customer2])).to eq([so2])
      expect(SaleOrder.of_users([user1])).to eq([so1])
      expect(SaleOrder.after([after + 1.day])).to eq([so2])
      expect(SaleOrder.before([before - 1.day])).to eq([so1])
      expect(SaleOrder.of_status([SaleOrder::Status::YET_TO_ALLOT])).to eq([so2,so1])
      expect(SaleOrder.of_status([SaleOrder::Status::BOOKED])).to eq([])
      expect(SaleOrder.of_experiment(true)).to eq([so2])
    end
  end

  context 'method test' do
    it "is_dispatched? and status" do
      sale_order = create(:central_sale_order)
      soi = create :soi_pomo, sale_order: sale_order
      material_order = sale_order.material_order
      shipment = create :farm_to_cso_shipment, recipient: material_order
      expect(sale_order.status).to eq(SaleOrder::Status::YET_TO_ALLOT)

      pickup = create(:pickup)
      shipment.update!(pickup_id: pickup.id)
      expect(sale_order.status).to eq(SaleOrder::Status::DISPATCHED)
      expect(sale_order.is_dispatched?).to eq(true)

      shipment.update!(pickup_id: nil)
      expect(sale_order.status).to eq(SaleOrder::Status::YET_TO_ALLOT)
    end

    it "is_so_deletable?" do
      soi = create :soi_pomo, sale_order: cso
      expect(cso.is_so_deletable?).to eq(true)
      material_order = cso.material_order
      shipment = create :farm_to_cso_shipment, recipient: material_order
      expect(cso.is_so_deletable?).to eq(false)
      soi1 = create :soi_pomo, sale_order: sale_order
      expect(sale_order.is_so_deletable?).to eq(true)
      sale_order.update!(status: SaleOrder::Status::VOID)
      expect(sale_order.is_so_deletable?).to eq(true)
      sale_order.update!(status: SaleOrder::Status::YET_TO_ALLOT)
      reg_track = create :regrade_tracker_for_allot_to_sale_order_item, sale_order_item: soi1
      soi1.update!(dispatched_weight: 10)
      expect(sale_order.is_so_deletable?).to eq(false)
    end

    it "mark_as_void" do
      sale_order = create(:central_sale_order)
      soi = create :soi_pomo, sale_order: sale_order
      params = {status: "Void", void_reason: "Test"}
      expect(sale_order.mark_as_void(params)).to eq(true)

      params = {status: "Partial_Allotment", void_reason: "Test"}
      expect { sale_order.mark_as_void(params) }.to raise_error(RuntimeError, "Cannot update Sale order status")
      
      sale_order1 = create(:sale_order)
      soi1 = create :soi_pomo, sale_order: sale_order1
      params = {status: "Void", void_reason: "Test"}
      reg_track = create :regrade_tracker_for_allot_to_sale_order_item, sale_order_item: soi1
      soi1.update!(dispatched_weight: 10)
      expect { sale_order1.mark_as_void(params) }.to raise_error(RuntimeError, "Assignment/Allotment/Grn/Retruns done, can't Void this sale order")
      
      sale_order.status = SaleOrder::Status::DRAFT
      params = {status: "Void", void_reason: "Test"}
      expect { sale_order.mark_as_void(params) }.to eq(true)

      sale_order.status = SaleOrder::Status::PARTIAL_ALLOT
      params = {status: "Void", void_reason: "Test"}
      expect { sale_order.mark_as_void(params) }.to raise_error(RuntimeError, "Cannot update Sale order status to #{params[:status]} when the status is #{sale_order.status}")

      sale_order.status = SaleOrder::Status::VOID
      params = {status: "Pending_Allotment", void_reason: ""}
      expect { sale_order.mark_as_void(params) }.to eq(true)

      sale_order.status = SaleOrder::Status::PARTIAL_ALLOT
      params = {status: "Pending_Allotment", void_reason: ""}
      expect { sale_order.mark_as_void(params) }.to raise_error(RuntimeError, "Cannot update Sale order status to #{params[:status]} when the status is #{sale_order.status}")



    end

    it "total_target_price" do
      soi = create :soi_pomo, sale_order: cso
      soi.update(dispatched_weight: 10)
      expect(cso.total_target_price).to eq(soi.target_price_per_kg*soi.dispatched_weight)
    end

    it "invoice_status" do
      expect(SaleOrder::Status::invoice_status).to eq([SaleOrder::Status::BOOKED, SaleOrder::Status::FULL_GRN, SaleOrder::Status::PENDING_GRN, SaleOrder::Status::PARTIAL_GRN, SaleOrder::Status::FULL_ALLOT, SaleOrder::Status::FLAGGED])
    end

    it "get_invoice_id" do
      hy_dc = create(:hyd_dc)
      sale_order = create :central_sale_order, dc: hy_dc
      expect(sale_order.get_invoice_id).to eq(1)
      sale_order.update(invoice_id: 17)
      sale_order1 = create :central_sale_order, dc: hy_dc
      expect(sale_order1.get_invoice_id).to eq(18)
      bg_dc = create(:dc)
      sale_order = create :sale_order, dc: bg_dc
      expect(sale_order.get_invoice_id).to eq(1)
    end

    it "cannot mark experiment if void" do 
      central_dc = create :dc_cdc
      sale_order = create :sale_order, status: SaleOrder::Status::VOID
      expect {update_with_shipment_and_sale_order_items!({"is_experiment": true, "experiment_reason": "Random"}, {}, {})}.to raise_error
    end
  end

  context 'association test' do
    it "belongs to user" do
      should belong_to(:user)
    end

    it "belongs to customer" do
      should belong_to(:customer)
    end

    it "has_many sale_order_items" do
      should have_many(:sale_order_items)
    end

    it "belongs to dc" do
      should belong_to(:dc)
    end

    it "has_one material_order" do
      should have_one(:material_order)
    end

    it "has_one recipient shipment" do
      should have_one(:recipient_shipment)
    end

    it "has_many sender shipments" do
      should have_many(:sender_shipments)
    end
  end

  context "Callback Tests" do
    it "block_if_allotted" do
      cso1 = create(:central_sale_order)
      soi = create :soi_pomo, sale_order: cso1
      cso1.destroy!
      expect(cso1.destroyed?).to eq(true)
      cso = create(:central_sale_order)
      soi = create :soi_pomo, sale_order: cso
      material_order = cso.material_order
      shipment = create :farm_to_cso_shipment, recipient: material_order
      expect {cso.destroy!}.to raise_error
      soi1 = create :soi_pomo, sale_order: sale_order
      sale_order.destroy!
      expect(sale_order.destroyed?).to eq(true)
      sale_order = create(:sale_order)
      soi1 = create :soi_pomo, sale_order: sale_order
      reg_track = create :regrade_tracker_for_allot_to_sale_order_item, sale_order_item: soi1
      soi1.update!(dispatched_weight: 10)
      expect {sale_order.destroy!}.to raise_error
    end

    it "block_if_allotted" do
      sale_order = create(:sale_order)
      soi1 = create :soi_pomo, sale_order: sale_order
      sale_order.update!(zoho_invoice_id: 10)
      expect {sale_order.destroy!}.to raise_error
    end

    it "check_back_date_so" do
      central_dc = create :dc_cdc
      SoBackDate.create(so_back_date: DateTime.now - 10)
      dc = create(:hyd_dc)
      customer = create(:customer_mt)
      customer_location = create(:customer_location)
      user = create(:sales_executive_user)
      expected_delivery_time = DateTime.now - 30
      params = {customer_id: customer.id,
                customer_location_id: customer_location.id,
                dc_id: dc.id,
                user_id: user.id,
                expected_delivery_time: expected_delivery_time}
      expect { SaleOrder.create(params) }.to raise_error
      params[:expected_delivery_time] = DateTime.now
      expect{ SaleOrder.create!(params) }.to change(SaleOrder,:count).by(1)
    end
  end

  it "exception_check_for_credit_limit_reached" do
    mo = create :material_order_for_central_sale_order
    sale_order = mo.sale_order
    soi = create :soi_pomo, ordered_weight: 100, sale_order: sale_order
    expect(sale_order.status).to eq(SaleOrder::Status::YET_TO_ALLOT)
    
    moi = create :moi_for_amo, material_order: mo
    child_mo_params = {
        "parent_material_order_id": mo.id,
        "sender_dc_id": sale_order.dc.id,
        "expected_delivery_time": Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)
      }

    child_moi_params = [{
      "ordered_weight": 1,
      "parent_material_order_item_id": moi.id
    }]
    child_mo = MaterialOrder.create_child_mo_with_mois!(child_mo_params, child_moi_params)
    
    shipment = mo.shipment
    trip = create :trip
    delivery = create :delivery, dc: shipment.recipient.dc, trip: trip 
    pickup = create(:pickup , trip: trip , vehicle_arrival_time: DateTime.now)
    
    shipment.update!(recipient_id: child_mo.id , pickup_id: pickup.id , delivery_id: delivery.id)
    sale_order.reload
    expect(sale_order.deliveries.count).to eq(1)
    
    dc_lot = create :sale_order_lot , shipment: shipment
    delivery.update!(vehicle_arrival_time: DateTime.now)
    shipment.reload
    expect(shipment.status).to eq(Shipment::Status::YET_TO_BE_DISPATCHED)


    hyd_dc = create :hyd_dc
    user = create :admin_user
    
    allotment_lot = {"id"=> dc_lot.id, "weight"=> 10 , "quantity"=>10}
    soi.customer.update!(credit_limit: 1)
    sale_order_allot_params = [{
        "id" => soi.id,
        "lots" => [allotment_lot],
        "user_id" => user.id,
        "dc_id" => hyd_dc.id
    }]
    
    expect {soi.sale_order.allot_for_sale_order(sale_order_allot_params)}.to raise_error("Can not update Sale Order as credit limit reached")
    delivery.reload
    expect(delivery.dc_lots.size).to eq(0)
  end

  context "Invoice Date Test" do
    it "check_invoice_date" do
      dc = create(:hyd_dc)
      customer = create(:customer_mt)
      customer_location = create(:customer_location)
      user = create(:sales_executive_user)
      expected_delivery_time = DateTime.now - 30
      params = {customer_id: customer.id,
                customer_location_id: customer_location.id,
                dc_id: dc.id,
                user_id: user.id,
                expected_delivery_time: expected_delivery_time}
      other_info = {}
      other_info['direct_sale'] = true 
      other_info['dc_id'] = dc.id
      other_info['created_by'] = user.id
      so = SaleOrder.create_with_shipment_and_sale_order_items!(params , {} , other_info )
      expect(so.invoice_date).to eq(so.expected_delivery_time)
    end
  end

  context 'method tests' do
    
    it "sale order source" do
      central_dc = create :dc_cdc
      dc = create(:hyd_dc)
      customer = create(:customer_mt)
      customer_location = create(:customer_location)
      user = create(:sales_executive_user)
      expected_delivery_time = DateTime.now - 30
      params = {customer_id: customer.id,
                customer_location_id: customer_location.id,
                dc_id: dc.id,
                user_id: user.id,
                expected_delivery_time: expected_delivery_time}
      params[:expected_delivery_time] = DateTime.now
      sale_order = SaleOrder.create!(params)
      expect(sale_order.source).to eq("NA") 

      mo = create :material_order_for_central_sale_order
      sale_order = mo.sale_order
      moi = create :moi_for_amo, material_order: mo
      dc_name = sale_order.dc.name
      child_mo_params = {
        "parent_material_order_id": mo.id,
        "sender_dc_id": sale_order.dc.id,
        "expected_delivery_time": Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)
      }
      child_moi_params = [{
      "ordered_weight": 1,
      "parent_material_order_item_id": moi.id
      }]
      child_mo = MaterialOrder.create_child_mo_with_mois!(child_mo_params, child_moi_params)  
      expect(sale_order.source).to eq(dc_name)

      dc = create :hyd_dc
      child_mo_params = {
        "parent_material_order_id": mo.id,
        "sender_dc_id": dc.id,
        "expected_delivery_time": Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)
      }
      child_moi_params = [{
      "ordered_weight": 1,
      "parent_material_order_item_id": moi.id
      }] 
      child_mo = MaterialOrder.create_child_mo_with_mois!(child_mo_params, child_moi_params)  
      expect(sale_order.source).to eq(dc_name)

    end

    it "so grn pending" do
      dc = create :dc_cdc
      user1 = create(:sales_executive_user)
      user2 = create(:sales_executive_user)
      sku1 = create(:sku_pomo)
      sku2 = create(:sku_kinnow_72)
      product_id1 = sku1.product_id
      product_id2 = sku2.product_id
      customer1 = create(:customer_mt)
      customer2 = create(:customer_mt)
      after = Date.today + 8.day
      before = Date.today + 10.day
      so1 = create :indirect_sale, expected_delivery_time: Date.today + 8.day, user: user1, customer: customer1, verification_status: "Verification_pending"
      so2 = create :indirect_sale, expected_delivery_time: Date.today + 10.day, user: user2, customer: customer2, is_experiment: true, experiment_reason: "abc", verification_status: "Verification_pending"
      soi1 = create :sale_order_item, sale_order: so1, sku: sku1
      soi2 = create :sale_order_item, sale_order: so2, sku: sku2
      expect(so1.so_grn_complete).to eq(false) 
      expect(so2.so_grn_complete).to eq(false)
      soi1.update_columns({:grn_weight => 20})
      soi2.update_columns({:grn_weight => 40})
      so1.update_status
      so2.update_status
      expect(so1.is_verified?).to eq(false) 
      expect(so2.is_verified?).to eq(false)
      expect(so1.status).to eq(SaleOrder::Status::PENDING_GRN)
      expect(so1.status).to eq(SaleOrder::Status::PENDING_GRN)
    end

    it "so grn complete" do
      dc = create :dc_cdc
      user1 = create(:sales_executive_user)
      user2 = create(:sales_executive_user)
      sku1 = create(:sku_pomo)
      sku2 = create(:sku_kinnow_72)
      product_id1 = sku1.product_id
      product_id2 = sku2.product_id
      customer1 = create(:customer_mt)
      customer2 = create(:customer_mt)
      after = Date.today + 8.day
      before = Date.today + 10.day
      so1 = create :indirect_sale, expected_delivery_time: Date.today + 8.day, user: user1, customer: customer1
      so2 = create :indirect_sale, expected_delivery_time: Date.today + 10.day, user: user2, customer: customer2, is_experiment: true, experiment_reason: "abc"
      soi1 = create :sale_order_item, sale_order: so1, sku: sku1
      soi2 = create :sale_order_item, sale_order: so2, sku: sku2
      expect(so1.so_grn_complete).to eq(false) 
      expect(so2.so_grn_complete).to eq(false)
      soi1.update_columns({:grn_weight => 20})
      soi2.update_columns({:grn_weight => 40})
      so1.update_columns({:verification_status => "Bill_upload"})
      so2.update_columns({:verification_status => "Bill_upload"})
      so1.update_status
      so2.update_status
      expect(so1.so_grn_complete).to eq(true) 
      expect(so2.so_grn_complete).to eq(true)
    end

  end  

end
