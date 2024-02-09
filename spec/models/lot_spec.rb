# == Schema Information
#
# Table name: lots
#
#  id                :bigint           not null, primary key
#  shipment_id       :bigint
#  lot_item_id       :bigint
#  quantity          :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  package_type      :string(255)
#  partial_weight    :float(24)        default(0.0)
#  identifier        :string(255)
#  parent_id         :bigint
#  average_weight    :float(24)
#  source_type       :string(255)
#  source_id         :bigint
#  has_partial       :boolean          default(FALSE)
#  sku_id            :bigint
#  current_weight    :float(24)
#  created_date      :datetime
#  description       :text(65535)
#  dc_id             :bigint
#  initial_weight    :float(24)
#  lot_type          :integer          default(1)
#  packaging_type_id :bigint
#
require 'rails_helper'
require_relative '../support/devise'

RSpec.describe Lot, type: :model do

  context "valid factory test" do 
    it { expect(create(:harvest_lot)).to be_valid }
    it { expect(create(:harvest_lot_with_partial)).to be_valid }
    it { expect(create(:dc_lot)).to be_valid }
    it { expect(create(:dc_lot_with_partial)).to be_valid }
    it { expect(create(:dc_lot_with_parent_lot)).to be_valid }
    it { expect(create(:dc_lot_with_grade_c)).to be_valid }
    it { expect(create(:dc_lot_with_parent_lot_and_partial)).to be_valid }
    it { expect(create(:direct_po_lot)).to be_valid }
    it { expect(create(:direct_po_dc_lot_with_parent_lot)).to be_valid }

    it { expect(create(:standard_dc_lot)).to be_valid }
    it { expect(create(:standard_dc_lot_with_partial)).to be_valid }
    it { expect(create(:standard_dc_lot_with_parent_lot)).to be_valid }
    it { expect(create(:standard_dc_lot_with_grade_c)).to be_valid }
    it { expect(create(:standard_dc_to_dc_shipment_lot)).to be_valid }
    it { expect(create(:standard_cso_to_dc_shipment_lot)).to be_valid }

    it { expect(create(:sale_order_lot)).to be_valid }
  end

  let(:harvest_lot) { create(:harvest_lot) }
  let(:harvest_lot_hyd_dc) { create(:harvest_lot_hyd_dc) }

  let(:harvest_lot_with_partial) { create(:harvest_lot_with_partial) }
  let(:direct_po_lot) { create(:direct_po_lot) }

  let(:dc_lot) { create(:dc_lot) }
  let(:dc_lot_with_partial) { create(:dc_lot_with_partial) }
  let(:dc_lot_with_parent_lot) { create(:dc_lot_with_parent_lot) }
  let(:dc_lot_with_parent_lot_and_partial) { create(:dc_lot_with_parent_lot_and_partial) }
  let(:dc_lot_with_grade_c) { create(:dc_lot_with_grade_c) }
  let(:cso_to_dc_shipment_lot) { create(:cso_to_dc_shipment_lot) }
  let(:direct_po_dc_lot_with_parent_lot) { create(:direct_po_dc_lot_with_parent_lot) }

  let(:standard_dc_lot) { create(:standard_dc_lot) }
  let(:standard_dc_lot_with_partial) { create(:standard_dc_lot_with_partial) }
  let(:standard_dc_lot_with_parent_lot) { create(:standard_dc_lot_with_parent_lot) }
  let(:standard_dc_lot_with_parent_lot_and_partial) { create(:standard_dc_lot_with_parent_lot_and_partial) }
  let(:standard_dc_lot_with_grade_c) { create(:standard_dc_lot_with_grade_c) }
  let(:standard_dc_to_dc_shipment_lot) { create(:standard_dc_to_dc_shipment_lot) }
  let(:standard_cso_to_dc_shipment_lot) { create(:standard_cso_to_dc_shipment_lot) }
  let(:packaging_item) { create(:nfi_packaging_item) }

  let(:sale_order_lot) { create(:sale_order_lot) }

  describe "ActiveModel validations" do
    # Basic validations
    it { should validate_numericality_of(:quantity) }
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:shipment).optional }
    it { should belong_to(:lot_item).optional }
    it { should belong_to(:parent_lot).optional }
    it { should belong_to(:dc).optional }
    it { should belong_to(:sku) }

    it { should have_one(:dc_lot) }
    it { should have_one(:sampling) }
    it { should have_one(:sale_order_items) }

    it { should have_many(:inventory_adjustments) }
    it { should have_many(:output_regradings) }
    it { should have_many(:output_regrade_trackers) }
    it { should have_many(:parent_regradings) }
    it { should have_many(:harvests) }

    it { should have_many(:qr_packaging_input_lots).class_name('Qr::PackagingInputLot').with_foreign_key(:lot_id) }
    it { should have_one(:qr_packaging_output_lot).class_name('Qr::PackagingOutputLot').with_foreign_key(:lot_id) }
  end

  context "Foreign Key Tests" do
    it "lot_sku" do
      sku = create(:sku)
      harvest_lot.sku = sku
      harvest_lot.save
      expect { sku.delete }.to raise_error
      expect { sku.destory! }.to raise_error
    end
    it "lot_shipment" do
      shipment = create(:dc_to_dc_shipment)
      harvest_lot.shipment = shipment
      harvest_lot.save
      expect { shipment.delete }.to raise_error
      shipment.destroy!
      expect {harvest_lot.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    it "lot_lot_item" do
      expect { harvest_lot.lot_item.delete }.to raise_error
      harvest_lot.lot_item.destroy!
      expect {harvest_lot.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end
    it "lot_packaging_item" do
      expect { harvest_lot.nfi_packaging_item.delete }.to raise_error
      expect {harvest_lot.nfi_packaging_item.destroy!}.to raise_error
    end
    it "lot_dc" do
      expect { dc_lot.dc.delete }.to raise_error
      expect {dc_lot.dc.destroy!}.to raise_error
    end
    it "lot_dc" do
      expect { dc_lot_with_parent_lot.parent_lot.delete }.to raise_error
      expect {dc_lot_with_parent_lot.parent_lot.destroy!}.not_to raise_error
    end
  end

  context 'scope tests' do
    it 'have valid scopes' do
      l1 = create :harvest_lot
      l2 = create :harvest_lot_with_partial
      l3 = create :dc_lot
      l4 = create :dc_lot_with_grade_c
      l5 = create :dc_to_dc_shipment_lot

      expect(Lot.purchase_lots.include? l1).to eq(true)
      expect(Lot.purchase_lots.include? l2).to eq(true)
      expect(Lot.purchase_lots.include? l3).to eq(false)
      expect(Lot.purchase_lots.include? l4).to eq(false)
      expect(Lot.purchase_lots.include? l5).to eq(false)
      expect(Lot.not_empty).to include(l1, l2)
    end

    it "dc in transit lot" do
      harvest_lot = create(:harvest_lot_hyd_dc)
      expect(Lot.dc_in_transit_lots(harvest_lot.shipment.delivery.dc_id)).to eq([harvest_lot])
    end

    describe '.exclude_packaging' do
      it 'excludes lots that are blocked for packaging' do
        blocked_lot = create(:lot, blocked_for_packaging: true)
        unblocked_lot = create(:lot, blocked_for_packaging: false)
  
        lots = Lot.exclude_packaging
  
        expect(lots).to include(unblocked_lot)
        expect(lots).not_to include(blocked_lot)
      end
    end
  
    describe '.of_packaging_process' do
      it 'includes lots that are blocked for packaging' do
        blocked_lot = create(:lot, blocked_for_packaging: true)
        unblocked_lot = create(:lot, blocked_for_packaging: false)
  
        lots = Lot.of_packaging_process
  
        expect(lots).to include(blocked_lot)
        expect(lots).not_to include(unblocked_lot)
      end
    end

    describe '.with_avg_weight(avg_weight)' do
      it 'should return lots with average_weight == avg_weight' do
        l1 = create(:dc_lot, average_weight: 10.0)

        expect(Lot.with_avg_weight(10)).to include(l1)
        expect(Lot.with_avg_weight(10.1)).not_to include(l1)
      end
    end

    describe '.with_age(days)' do
      it 'should return lots with same age as days' do
        l1 = create(:dc_lot, created_date: 5.days.ago)

        expect(Lot.with_age(5)).to include(l1)
        expect(Lot.with_age(4)).not_to include(l1)
        expect(Lot.with_age(6)).not_to include(l1)
      end
    end
    
  end

  describe '#validate_packaging_lots' do
    it 'raises an error if the lot is blocked for packaging and tracker_type is not PackagingProcess' do
      lot = create(:lot, blocked_for_packaging: true)
      expect { lot.validate_packaging_lots(RegradeTracker::TrackerType::REGRADE) }
        .to raise_error(ActionController::BadRequest)
    end
  
    it 'does not raise an error if the lot is blocked for packaging and tracker_type is PackagingProcess' do
      lot = create(:lot, blocked_for_packaging: true)
      expect { lot.validate_packaging_lots(RegradeTracker::TrackerType::PackagingProcess) }
        .not_to raise_error
    end
  
    it 'raises an error if the lot is not blocked for packaging and tracker_type is PackagingProcess' do
      lot = create(:lot)
      expect { lot.validate_packaging_lots(RegradeTracker::TrackerType::PackagingProcess) }
        .to raise_error(ActionController::BadRequest)
    end
  
    it 'does not raise an error if the lot is not blocked for packaging and tracker_type is not PackagingProcess' do
      lot = create(:lot)
      expect { lot.validate_packaging_lots(RegradeTracker::TrackerType::REGRADE) }
        .not_to raise_error
    end
  end
  

  context "model methods test" do
    before do
      create(:dc_cdc)
    end
    it "group_by_products" do
      dc = create :hyd_dc
      dc_2 = create :dc 
      dc_3 = create :dc
      p1 = create :pomo
      p2 = create :orange
      sku1 = create :sku, product: p1
      sku2 = create :sku_pomo
      sku3 = create :sku_kinnow_72, product: p2
      lot_1 = create :dc_lot, sku: sku1, dc: dc
      lot_2 = create :dc_lot, sku: sku1, dc: dc
      lot_3 = create :dc_lot, sku: sku2, dc: dc_2
      lot_4 = create :dc_lot, sku: sku3, dc: dc
      lots =  Lot.of_dc(dc.id)
      
      expect(Lot.of_dc(dc.id).count).to eq(3)
      grouped_product_lots = Lot.group_by_products(lots)
      lots = Lot.of_dc(dc_2.id)
      grouped_product_lots_2 = Lot.group_by_products(lots)
      lots = Lot.of_dc(dc_3.id)
      grouped_product_lots_3 = Lot.group_by_products(lots)
      
      expect(grouped_product_lots_3).to eq([]
      )
      expect(grouped_product_lots).to eq([
        {:product => p1, :lots=>[lot_1, lot_2]},
        {:product => p2, :lots=>[lot_4]}
      ])
      expect(grouped_product_lots_2).to eq([
        {:product => p1, :lots=>[lot_3]}, 
      ])
      expect(grouped_product_lots.length).to eq(2)
      expect(grouped_product_lots[0][:product]).to eq(p1)
      expect(grouped_product_lots[0][:lots]).to contain_exactly(lot_1, lot_2)
      expect(grouped_product_lots[1][:product]).to eq(p2)
      expect(grouped_product_lots[1][:lots]).to contain_exactly(lot_4)
    end

    it 'apply_filters' do
      dc = create :hyd_dc
      p1 = create :pomo
      sku1 = create :sku, product: p1
      lot_1 = create :dc_lot, sku: sku1, dc: dc, lot_type:Lot::LotType::NONSTANDARD
      lot_2 = create :dc_lot, sku: sku1, dc: dc, lot_type:Lot::LotType::STANDARD
      filters = {
          'dcid' => dc.id,
          'sku_ids' => sku1.id,
          'product_ids' => p1.id,
          'lot_type' => 1
      }
      puts "product ids"
      puts sku1.product.id
      result = Lot.apply_filters(filters.to_h)
      expect(result.count).to eq(1)
      expect(result.first.dc_id).to eq(dc.id)
      expect(result.pluck(:dc_id).uniq).to contain_exactly(dc.id)
      expect(result.pluck(:sku_id).uniq).to contain_exactly(sku1.id)
      expect(result.pluck(:lot_type).uniq).to contain_exactly(Lot::LotType::NONSTANDARD)
    end

    it "material_grade" do
      expect(harvest_lot.material_grade).to eq(harvest_lot.sku.grade)
      expect(dc_lot.material_grade).to eq(dc_lot.sku.grade)
      expect(standard_dc_lot.material_grade).to eq(standard_dc_lot.sku.grade)
    end

    it "harvest_id" do
      expect(harvest_lot.harvest_id).to eq(harvest_lot.harvest.id)
      expect(dc_lot.harvest_id).to eq(nil)
      expect(standard_dc_lot.harvest_id).to eq(nil)
    end

    it "is_dc_lot?" do
      expect(harvest_lot.is_dc_lot?).to eq(false)
      expect(dc_lot.is_dc_lot?).to eq(true)
      expect(standard_dc_lot.is_dc_lot?).to eq(true)
    end

    it "is_transit_lot?" do
      expect(harvest_lot.is_transit_lot?).to eq(true)
      expect(dc_lot.is_transit_lot?).to eq(false)
      expect(standard_dc_lot.is_transit_lot?).to eq(false)
    end
  
    it "is_harvest_lot?" do
      expect(harvest_lot.is_harvest_lot?).to eq(true)
      expect(dc_lot.is_harvest_lot?).to eq(false)
      expect(standard_dc_lot.is_harvest_lot?).to eq(false)
    end

    it "is_purchase_order_lot?" do
      expect(harvest_lot.is_purchase_order_lot?).to eq(true)
      expect(dc_lot.is_purchase_order_lot?).to eq(false)
      expect(standard_dc_lot.is_purchase_order_lot?).to eq(false)
    end

    it "is_transfer_order_lot?" do
      expect(cso_to_dc_shipment_lot.is_transfer_order_lot?).to eq(true)
      expect(dc_lot.is_transfer_order_lot?).to eq(false)
      expect(harvest_lot.is_transfer_order_lot?).to eq(false)
    end

    it "is_sale_order_lot?" do
      expect(sale_order_lot.is_sale_order_lot?).to eq(true)
      expect(cso_to_dc_shipment_lot.is_sale_order_lot?).to eq(false)
      expect(dc_lot.is_sale_order_lot?).to eq(false)
      expect(harvest_lot.is_sale_order_lot?).to eq(false)
    end

    it "parent_lot_quantity" do
      expect(dc_lot_with_parent_lot.parent_lot_quantity).to eq(11)
      expect(harvest_lot.parent_lot_quantity).to eq(nil)
      expect(dc_lot.parent_lot_quantity).to eq(nil)
    end

    it "parent_lot_shipment_id" do
      expect(dc_lot_with_parent_lot.parent_lot_shipment_id).not_to be(nil)
      expect(harvest_lot.parent_lot_shipment_id).to be(nil)
      expect(dc_lot.parent_lot_shipment_id).to be(nil)
    end

    it "lot_age" do
      expect(harvest_lot.lot_age).to be(1)
      expect(dc_lot.lot_age).to be(1)
    end

    it "average_weight_rounded" do
      expect(harvest_lot.average_weight_rounded).to be(9.5)
    end

    it "lot_partial_weight" do
      expect(harvest_lot_with_partial.lot_partial_weight).to be(5.0)
      expect(dc_lot_with_partial.lot_partial_weight).to be(5.0)
      expect(dc_lot.lot_partial_weight).to be(0.0)
    end

    it "initial_weight_in_kgs" do
      expect(dc_lot_with_partial.initial_weight_in_kgs).to be(100.0)
      expect(dc_lot.initial_weight_in_kgs).to be(95.0)
      expect(harvest_lot.initial_weight_in_kgs).to be(95.0)
    end

    it "harvest_lot_with_partial: lot_quantity" do
      expect(harvest_lot_with_partial.lot_quantity).to be(11)
    end

    it "harvest_lot_with_partial: weight_in_kgs" do
      expect(harvest_lot_with_partial.weight_in_kgs).to be(100.0)
    end
    
    it "initial_deduced_weight_in_kgs" do
      expect(harvest_lot_with_partial.initial_deduced_weight_in_kgs).to be(100.0)
      expect(dc_lot_with_partial.initial_deduced_weight_in_kgs).to be(100.0)
    end

    it "harvest_lot_with_partial: agreed_value" do
      expect(harvest_lot_with_partial.agreed_value).to be(15.0)
      expect(dc_lot.agreed_value).to be(nil)
    end

    it "value" do
      expect(harvest_lot_with_partial.value).to be(1500.0)
      expect(dc_lot_with_partial.value).to be(nil)
    end

    it "package_code" do
      expect(harvest_lot_with_partial.package_code).to eq('CRAT')
      expect(dc_lot.package_code).to eq('CRAT')
    end

    it "material_code" do
      expect(harvest_lot_with_partial.material_code).to eq('POMO')
      expect(dc_lot.material_code).to eq('POMO')
    end

    it "material_grade" do
      expect(harvest_lot_with_partial.material_grade).to eq('200-300')
      expect(dc_lot.material_grade).to eq('200-300')
    end

    it "harvest_day_code" do
      expect(harvest_lot_with_partial.harvest_day_code).to eq(1.day.ago.strftime('%d%m%y'))
      expect(dc_lot.harvest_day_code).to eq(nil)
      expect(sale_order_lot.harvest_day_code).to eq(nil)
    end

    it "is_grade_c" do
      expect(harvest_lot_with_partial.is_grade_c?).to be(false)
      expect(dc_lot_with_grade_c.is_grade_c?).to be(true)
    end

    it "dc_lot: label" do
      expect(dc_lot.label).to eq('DC-LOT/POMO/200-300')
    end

    it "harvest_lot_with_partial: update_lot" do
      lot_attr = {quantity: 15,
                  average_weight: 10.523,
                  has_partial: false}
      harvest_lot_with_partial.update_lot!(lot_attr)

      expect(harvest_lot_with_partial.quantity).to eq(15)
      expect(harvest_lot_with_partial.lot_quantity).to eq(15)
      expect(harvest_lot_with_partial.average_weight).to eq(10.523)
      expect(harvest_lot_with_partial.average_weight_rounded).to eq(10.52)
      expect(harvest_lot_with_partial.has_partial).to eq(false)

      lot_attr = {has_partial: true}
      harvest_lot_with_partial.update_lot!(lot_attr)

      expect(harvest_lot_with_partial.quantity).to eq(15)
      expect(harvest_lot_with_partial.lot_quantity).to eq(16)
      expect(harvest_lot_with_partial.average_weight).to eq(10.523)
      expect(harvest_lot_with_partial.average_weight_rounded).to eq(10.52)
      expect(harvest_lot_with_partial.has_partial).to eq(true)
    end

    it "dc_lot_with_parent_lot_and_partial: unloading" do
      dc_lot_with_parent_lot_and_partial = create(:dc_lot_with_parent_lot_and_partial)
      dc_lot_with_parent_lot_and_partial.parent_lot.shipment.delivery = create(:delivery)
      dc_lot_with_parent_lot_and_partial.parent_lot.shipment.delivery.vehicle_arrival_time = Time.now

      lot_attr = {quantity: 8,
                  average_weight: 8.523,
                  has_partial: false}
      dc_lot_with_parent_lot_and_partial.update_lot!(lot_attr)

      transit_gap_inv_adj = InventoryAdjustment.where({source_type: InventoryAdjustment::SourceType::DcDeliveryLot, reason: InventoryAdjustment::Reason::TransitGap, lot_id: dc_lot_with_parent_lot_and_partial.id}).first
      transit_moisture_loss_inv_adj = InventoryAdjustment.where({source_type: InventoryAdjustment::SourceType::DcDeliveryLot, reason: InventoryAdjustment::Reason::TransitMoistureLoss, lot_id: dc_lot_with_parent_lot_and_partial.id}).first

      expect(dc_lot_with_parent_lot_and_partial.quantity).to eq(8)
      expect(dc_lot_with_parent_lot_and_partial.lot_quantity).to eq(8)
      expect(dc_lot_with_parent_lot_and_partial.average_weight).to eq(8.523)
      expect(dc_lot_with_parent_lot_and_partial.average_weight_rounded).to eq(8.52)
      expect(dc_lot_with_parent_lot_and_partial.has_partial).to eq(false)
      expect(transit_gap_inv_adj.weight).to eq(24.0)
      expect(transit_moisture_loss_inv_adj.weight).to eq(7.816)
      
      lot_attr = {has_partial: true}
      dc_lot_with_parent_lot_and_partial.update_lot!(lot_attr)
      
      transit_gap_inv_adj = InventoryAdjustment.where({source_type: InventoryAdjustment::SourceType::DcDeliveryLot, reason: InventoryAdjustment::Reason::TransitGap, lot_id: dc_lot_with_parent_lot_and_partial.id}).first
      transit_moisture_loss_inv_adj = InventoryAdjustment.where({source_type: InventoryAdjustment::SourceType::DcDeliveryLot, reason: InventoryAdjustment::Reason::TransitMoistureLoss, lot_id: dc_lot_with_parent_lot_and_partial.id}).first

      expect(dc_lot_with_parent_lot_and_partial.quantity).to eq(8)
      expect(dc_lot_with_parent_lot_and_partial.lot_quantity).to eq(9)
      expect(dc_lot_with_parent_lot_and_partial.average_weight).to eq(8.523)
      expect(dc_lot_with_parent_lot_and_partial.average_weight_rounded).to eq(8.52)
      expect(dc_lot_with_parent_lot_and_partial.has_partial).to eq(true)
      expect(transit_gap_inv_adj.weight).to eq(19.0)
      expect(transit_moisture_loss_inv_adj.weight).to eq(7.816)
    end

    it "child_lot_to_do_partial_unloading:  partial_unloading" do
      child_l = create(:child_lot_to_do_partial_unloading) #initial parent_lot: quantity => 10
      delivery = child_l.parent_lot.shipment.delivery
      delivery.status = Delivery::Status::PARTIALLY_UNLOADED
      delivery.save!
      child_l.dc_id = delivery.dc_id
      child_l.save
      params = [{ id: child_l.id, quantity: 2, is_full_unload: false }.with_indifferent_access]
      user = create(:user)
      Lot.update_many_partially!(params, user)

      expect(child_l.reload.quantity).to eq(2)
      expect(child_l.parent_lot.to_be_unloaded).to eq(8)
      expect(child_l.parent_lot.shipment.delivery.status).to eq(Delivery::Status::PARTIALLY_UNLOADED)

      params = [{ id: child_l.id, quantity: 7, is_full_unload: true }.with_indifferent_access]
      Lot.update_many_partially!(params, user)
      expect(child_l.reload.quantity).to eq(9)
      expect(child_l.parent_lot.to_be_unloaded).to eq(0)
      expect(child_l.parent_lot.shipment.delivery.status).to eq(Delivery::Status::UNLOADED)
    end

    it "dc_lot_with_parent_lot_and_partial: update_lot : already regraded lot" do
      lot = dc_lot_with_parent_lot_and_partial
      btype = PackagingType.find_by_code("BOX")
      lots = {
        "input":[{
          id: lot.id,
          weight: 4.5
        }],
        "output":[{
          "weight":1.3,
          "nfi_packaging_item_id": packaging_item.id,
          "description":"",
          "sku_id":lot.sku.id
        }]
      }
      user = create(:dc_executive_user)
      regrade_tracker_params = {
                                "moisture_loss":1.5,
                                "grade_c_weight":1.7,
                                "start_time":1623840720000,
                                "end_time":1623927060000,
                                "dc_id": lot.dc_id,
                                "user_id": user.id
                                }
                          
      RegradeTracker.create_tracker!(regrade_tracker_params, lots)

      lot_attr = {quantity: 15,
                  average_weight: 10.523,
                  has_partial: false}

      expect { lot.reload.update_lot!(lot_attr) }.to raise_error
    end

    it "dc_lot_with_parent_lot_and_partial: unloading" do
      lot = dc_lot_with_parent_lot_and_partial
      lot.parent_lot.shipment.delivery = create(:delivery)
      lot.parent_lot.shipment.delivery.vehicle_arrival_time = Time.now
      btype = PackagingType.find_by_code("BOX")

      lots = {
        "input":[{
          id: lot.id,
          weight: 4.5
        }],
        "output":[{
          "weight":1.3,
          "nfi_packaging_item_id": packaging_item.id,
          "description":"",
          "sku_id":lot.sku.id
        }]
      }
      user = create(:dc_executive_user)
      regrade_tracker_params = {
                                "moisture_loss":1.5,
                                "grade_c_weight":1.7,
                                "start_time":1623840720000,
                                "end_time":1623927060000,
                                "dc_id": lot.dc_id,
                                "user_id": user.id
                                }
                          
      RegradeTracker.create_tracker!(regrade_tracker_params, lots)

      lot_attr = {quantity: 8,
                  average_weight: 8.523,
                  has_partial: false}

      expect { lot.reload.unload_lot!(lot_attr) }.to raise_error      
    end

    it "unloaded_dc_lot?" do
      expect(harvest_lot.unloaded_dc_lot?).to eq(false)
      expect(harvest_lot_with_partial.unloaded_dc_lot?).to eq(false)
      expect(dc_lot.unloaded_dc_lot?).to eq(false)
      expect(dc_lot_with_partial.unloaded_dc_lot?).to eq(false)
      expect(dc_lot_with_parent_lot.unloaded_dc_lot?).to eq(true)
      expect(dc_lot_with_parent_lot_and_partial.unloaded_dc_lot?).to eq(true)
      expect(dc_lot_with_grade_c.unloaded_dc_lot?).to eq(false)
      expect(cso_to_dc_shipment_lot.unloaded_dc_lot?).to eq(false)
      expect(standard_dc_lot.unloaded_dc_lot?).to eq(false)
      expect(standard_dc_lot_with_partial.unloaded_dc_lot?).to eq(false)
      expect(standard_dc_lot_with_parent_lot.unloaded_dc_lot?).to eq(true)
      expect(standard_dc_lot_with_parent_lot_and_partial.unloaded_dc_lot?).to eq(true)
      expect(standard_dc_lot_with_grade_c.unloaded_dc_lot?).to eq(false)
      expect(standard_dc_to_dc_shipment_lot.unloaded_dc_lot?).to eq(false)
      expect(standard_cso_to_dc_shipment_lot.unloaded_dc_lot?).to eq(false)
      expect(sale_order_lot.unloaded_dc_lot?).to eq(false)
    end

    it "allow_update_inventory_adjustments?" do
      parent_lot = dc_lot_with_parent_lot.parent_lot
      expect(dc_lot_with_parent_lot.allow_update_inventory_adjustments?).to eq(false)
      parent_lot.shipment.delivery.update(vehicle_arrival_time: Time.now)
      expect(dc_lot_with_parent_lot.allow_update_inventory_adjustments?).to eq(true)
      dc_lot_with_parent_lot.skip_update_inventory = true
      expect(dc_lot_with_parent_lot.allow_update_inventory_adjustments?).to eq(false)
      dc_lot_with_parent_lot.skip_update_inventory = false
      parent_lot.shipment.delivery.update(status: Delivery::Status::COMPLETED)
      expect(dc_lot_with_parent_lot.allow_update_inventory_adjustments?).to eq(true)
    end

    it "is_moi_lot?" do
      lot = create(:moi_lot)
      expect(lot.is_moi_lot?).to eq(true)
      lot.update!(material_order_item_id: nil)
      expect(lot.is_moi_lot?).to eq(false)
    end

    it "change_mo_status" do
      mo = create :mo_with_child_mo_for_amo
      expect(mo[:status]).to eq(MaterialOrder::Status::ASSIGNED_TO_SUPPLY)
      lot = create :moi_lot, material_order_item: mo.child_mos.first.material_order_items.first
      mo.reload
      expect(mo[:status]).to eq(MaterialOrder::Status::ALLOTTED)
      Lot.destroy(lot.id)
      mo.reload
      expect(mo[:status]).to eq(MaterialOrder::Status::ASSIGNED_TO_SUPPLY)
    end

    it "lot_so_history" do
      lot = create :dc_lot
      user = create :demand_head 
      expect(lot.lot_so_history).to eq([])
      soi = create :soi_pomo
      moi = create :moi_pomo

      soi_allot_attrs = {
        lots: [{id: lot.id, weight: 10}],
        user_id: user.id
      }

      moi_allot_params = {
        id: moi.id,
        lots: [{id: lot.id, weight: 20, average_weight: 10, nfi_packaging_item_id: packaging_item.id, partial_weight: 0, has_partial: false, quantity: 2}],
        user_id: user.id
      }

      SaleOrderItem.allot(soi, soi_allot_attrs)
      lot.reload
      expect(lot.lot_so_history).to eq([{so_id: soi.sale_order.id, weight: 10}])
      moi.allot!(moi_allot_params)
      lot.reload
      expect(lot.lot_so_history).to eq([{so_id: soi.sale_order.id, weight: 10}, {so_id: moi.sale_order_item.sale_order.id, weight: 20}])
    end

    it "block_for_packaging" do
      # "marks the lot as blocked for packaging" 
      lot = create :lot
      expect { lot.block_for_packaging }.to change { lot.reload.blocked_for_packaging }.from(false).to(true)

      # "raises an error when lot is already blocked for packaging"
      expect { lot.block_for_packaging }.to raise_error(RuntimeError, "Lot-##{lot.id} was already blocked for packaging!")
    end

    it "unblock_from_packaging" do
      # marks the lot as unblocked from packaging
      lot = create(:lot, blocked_for_packaging: true)
      expect { lot.unblock_from_packaging }.to change { lot.reload.blocked_for_packaging }.from(true).to(false)

      # raises an error when lot is already unblocked from packaging
      expect { lot.unblock_from_packaging }.to raise_error(RuntimeError, "Lot-##{lot.id} was already unblocked from packaging!")
    end
  end

  context "Callback Tests" do
    it "create_samplings" do
      expect(harvest_lot.sampling.present?).to eq(false)
      expect(harvest_lot_with_partial.sampling.present?).to eq(false)
      expect(dc_lot.sampling.present?).to eq(false)
      expect(dc_lot_with_partial.sampling.present?).to eq(false)
      expect(dc_lot_with_parent_lot.sampling.present?).to eq(true)
      expect(dc_lot_with_parent_lot_and_partial.sampling.present?).to eq(true)
      expect(dc_lot_with_grade_c.sampling.present?).to eq(false)
      expect(cso_to_dc_shipment_lot.sampling.present?).to eq(false)
      expect(standard_dc_lot.sampling.present?).to eq(false)
      expect(standard_dc_lot_with_partial.sampling.present?).to eq(false)
      expect(standard_dc_lot_with_parent_lot.sampling.present?).to eq(true)
      expect(standard_dc_lot_with_parent_lot_and_partial.sampling.present?).to eq(true)
      expect(standard_dc_lot_with_grade_c.sampling.present?).to eq(false)
      expect(standard_dc_to_dc_shipment_lot.sampling.present?).to eq(false)
      expect(standard_cso_to_dc_shipment_lot.sampling.present?).to eq(false)
      expect(sale_order_lot.sampling.present?).to eq(false)
      expect(direct_po_lot.sampling.present?).to eq(false)
      expect(direct_po_dc_lot_with_parent_lot.sampling.present?).to eq(false)
    end
  end

  context 'validation tests' do
    it "lot_cannot_be_updated_after_shipment_is_delivered" do
      lot = harvest_lot_hyd_dc
      expect {lot.update!(quantity: 2)}.not_to raise_error
      expect {lot.update!(has_partial: true, partial_weight: 2)}.not_to raise_error
      lot.delivery.update!(vehicle_arrival_time: DateTime.now)
      expect {lot.update!(quantity: 3)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Can not update lot as shipment is delivered')
      expect {lot.update!(has_partial: true, partial_weight: 3)}.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Can not update lot as shipment is delivered')
    end
  end

end
