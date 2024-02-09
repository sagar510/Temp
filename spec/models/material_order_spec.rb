# == Schema Information
#
# Table name: material_orders
#
#  id                       :bigint           not null, primary key
#  dc_id                    :bigint
#  user_id                  :bigint
#  order_created_time       :datetime
#  loading_time             :datetime
#  expected_delivery_time   :datetime
#  comments                 :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  sale_order_id            :bigint
#  sender_dc_id             :bigint
#  sender_purchase_order_id :bigint
#  parent_material_order_id :bigint
#
require 'rails_helper'

RSpec.describe MaterialOrder, type: :model do
  context 'factory validation tests' do
    it "material_order has a valid factory" do
      expect(FactoryBot.create(:material_order)).to be_valid
    end

    it "material_order_for_central_sale_order has a valid factory" do
      expect(FactoryBot.create(:material_order_for_central_sale_order)).to be_valid
    end
  end

  context 'scope tests' do
    it 'of_status' do
      mos = create_list :unapproved_amo, 3
      user = create :admin_user
      expect(MaterialOrder.of_status(MaterialOrder::Status::PENDING_APPROVAL).count).to eq(3)
      expect(MaterialOrder.of_status(MaterialOrder::Status::UNAPPROVED).count).to eq(0)
      mos.first.update!(approver_id: user.id, status: MaterialOrder::Status::APPROVED)

      expect(MaterialOrder.of_status(MaterialOrder::Status::PENDING_APPROVAL).count).to eq(2)
      expect(MaterialOrder.of_status(MaterialOrder::Status::UNAPPROVED).count).to eq(0)
      mos.last.update!(approver_id: user.id, status: MaterialOrder::Status::APPROVED)

      expect(MaterialOrder.of_status(MaterialOrder::Status::PENDING_APPROVAL).count).to eq(1)
      expect(MaterialOrder.of_status(MaterialOrder::Status::UNAPPROVED).count).to eq(0)
    end

    it 'has_no_shipments' do
      mo = create :material_order
      expect(MaterialOrder.has_no_shipments.where(id:mo.id).present?).to eq(true)
      shipment = create :dc_to_dc_shipment, recipient: mo
      expect(MaterialOrder.has_no_shipments.where(id:mo.id).present?).to eq(false)
    end  
  end

  context 'association test' do
    it "belongs to destinationdc" do
      should belong_to(:dc)
    end

    it "delongs_to sale_order" do
      should belong_to(:sale_order).optional
    end

    it "has_one shipments" do
      should have_one(:shipment)
    end
  end

  context 'after_update callbacks' do
    it 'triggers a SendSlackNotification => case : [APPROVED]' do
      mo = create :mo_for_amo
      allow(mo).to receive(:allow_slack_notification?).and_return(true)
      allow(mo).to receive(:send_slack_notification)
      mo.status = MaterialOrder::Status::APPROVED
      mo.save
      expect(mo).to have_received(:send_slack_notification)
    end

    it 'triggers a SendSlackNotification => case : [ASSIGNED_TO_SUPPLY]' do
      mo = create :mo_for_amo
      allow(mo).to receive(:allow_slack_notification?).and_return(true)
      allow(mo).to receive(:send_slack_notification)
      mo.status = MaterialOrder::Status::ASSIGNED_TO_SUPPLY
      mo.save
      expect(mo).to have_received(:send_slack_notification)
    end

    it 'triggers a SendSlackNotification => case : [ALLOTTED]' do
      mo = create :mo_for_amo
      allow(mo).to receive(:allow_slack_notification?).and_return(true)
      allow(mo).to receive(:send_slack_notification)
      mo.status = MaterialOrder::Status::ALLOTTED
      mo.save
      expect(mo).to have_received(:send_slack_notification)
    end
  end

  context 'method tests' do
    it 'any_soi_of_moi_edited?' do
      mo = create :mo_with_moi_and_soi_for_amo
      expect(mo.any_soi_of_moi_edited?).to eq(false)
      mo.material_order_items.first.sale_order_items.first.update!(ordered_weight: 13)
      mo.reload
      expect(mo.any_soi_of_moi_edited?).to eq(true)
    end

    it 'has_any_assignment?' do
      mo = create :mo_for_amo
      expect(mo.has_any_assignment?).to eq(false)
      mo_with_child_mo = create :mo_with_child_mo_for_amo
      expect(mo_with_child_mo.has_any_assignment?).to eq(true)
    end

    it 'is_child_mo?' do
      mo = create :mo_for_amo
      expect(mo.is_child_mo?).to eq(false)
      child_mo = create :child_mo_for_amo
      expect(child_mo.is_child_mo?).to eq(true)
    end

    it 'has_any_allotment?' do
      mo = create :mo_for_amo
      expect(mo.has_any_allotment?).to eq(false)
      allotted_mo = create :mo_with_allotted_child_mo_for_amo
      lot = create :moi_lot, material_order_item: allotted_mo.child_mos[0].material_order_items[0]
      allotted_mo.child_mos[0].material_order_items[0].reload
      expect(allotted_mo.has_any_allotment?).to eq(true)
    end

    it 'change_mo_status' do
      mo = create :approved_amo
      expect(mo[:status]).to eq(MaterialOrder::Status::APPROVED)
      child_mo = create :child_mo_for_amo, parent_material_order: mo
      expect(mo[:status]).to eq(MaterialOrder::Status::ASSIGNED_TO_SUPPLY)
      child_mo.destroy!
      expect(mo[:status]).to eq(MaterialOrder::Status::APPROVED)
    end
    
    it 'create_child_mo_with_mois_and_to!' do 
      dc = create :hyd_dc
      mo = create :approved_amo
      mo.sender_dc = dc
      moi = create :moi_for_amo, material_order: mo
      child_mo_params = {
          "parent_material_order_id": mo.id,
          "sender_dc_id": dc.id,
          "expected_delivery_time": Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)
        }

      child_moi_params = [{
        "ordered_weight": 1,
        "parent_material_order_item_id": moi.id
      }]
      
      child_mo = MaterialOrder.create_child_mo_with_mois_and_to!(child_mo_params, child_moi_params)
      expect(child_mo.shipment.recipient_id).to eq(child_mo.id)
      expect(Shipment.non_cdc_transfer_orders(dc.id).where(id:child_mo.shipment.id).present?).to eq(true)
    end

    it 'create_child_mo_with_mois!' do 
      dc = create :hyd_dc
      mo = create :approved_amo
      mo.sender_dc = dc
      moi = create :moi_for_amo, material_order: mo
      expect(mo.child_mos.count).to eq(0)
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
      expect(child_mo.parent_material_order_id).to eq(mo.id)
      expect(mo.child_mos.count).to eq(1)
      expect(mo.material_order_items.pluck(:id)).to include(*child_mo.material_order_items.pluck(:parent_material_order_item_id))
    end

    it 'check moi source' do 
      dc = create :hyd_dc
      mo = create :approved_amo
      mo.sender_dc = dc
      moi = create :moi_for_amo, material_order: mo
      expect(mo.child_mos.count).to eq(0)
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
      expect(mo.mo_source).to eq("Hyderabad")
      expect(child_mo.mo_source).to eq("Hyderabad")
    end

    it 'is_editable?' do
      mo = create :unapproved_amo
      expect(mo.is_editable?).to eq(true)
      mo.update!(status: MaterialOrder::Status::APPROVED)
      expect(mo.is_editable?).to eq(false)
    end

    it 'create_mo_with_moi!' do 
      dc = create :hyd_dc
      user = create :admin_user 
      mo = create :unapproved_amo
      moi = create :moi_for_amo
      mo_params = mo.attributes.except("id")
      moi_params = [moi.attributes.except("id")]

      mo = MaterialOrder.create_mo_with_moi!(mo_params, moi_params)
      expect(mo.status).to eq(MaterialOrder::Status::PENDING_APPROVAL)
      expect(mo.material_order_items.count).to eq(1)
    end

    it 'check_unique_products_category' do
      sku1 = create :sku_pomo
      sku2 = create :sku_kinnow_72
      product_1 = create :pomo
      product_2 = create :kinnow
      moi_params_array = [
        {
          "ordered_weight": 1,
          "sku_id": sku1.id
        },
        {
          "ordered_weight": 2,
          "sku_id": sku2.id
        }
      ]
      expect(MaterialOrder.check_unique_products_category(moi_params_array)).to be_falsey
    end    
    
    it 'reject_mo' do 
      dc = create :hyd_dc
      mo = create :unapproved_amo
      moi = create :moi_for_amo
      user = create :admin_with_category

      mo_params = mo.attributes.except("id")
      moi_params = [moi.attributes.except("id")]

      mo = MaterialOrder.create_mo_with_moi!(mo_params, moi_params)
      mo.reject_mo({:reject_reason => 1, :remark =>"some", :rejected_by_id => user.id, :rejected_date => DateTime.now()})
      expect(mo.status).to eq(MaterialOrder::Status::REJECTED)
      expect { mo.reject_mo({:reject_reason => 1, :remark =>"some", :rejected_by_id => user.id, :rejected_date => DateTime.now()}) }.to raise_error

      # sale_order = create(:central_sale_order)
      # soi = create :soi_pomo, sale_order: sale_order
      # material_order = sale_order.material_order
      # material_order.reject_mo({:reject_reason => 1, :remark =>"some", :rejected_by_id => user.id, :rejected_date => DateTime.now()})
      # expect(material_order.status).to eq(MaterialOrder::Status::REJECTED)
      # sale_order.reload
      # expect(sale_order.status).to eq(SaleOrder::Status::VOID)
    end
  end
end
