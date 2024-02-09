# == Schema Information
#
# Table name: regrade_trackers
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint           not null
#  dc_id                  :bigint
#  product_id             :bigint           not null
#  start_time             :datetime
#  end_time               :datetime
#  comments               :text(65535)
#  moisture_loss          :float(24)
#  grade_c_weight         :float(24)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sale_order_item_id     :bigint
#  tracker_type           :integer          not null
#  material_order_item_id :bigint
#
require 'rails_helper'

RSpec.describe RegradeTracker, type: :model do

  context "valid factory test" do 
    it { expect(create(:regrade_tracker_for_regrade)).to be_valid }
    it { expect(create(:regrade_tracker_for_merge)).to be_valid }
    it { expect(create(:regrade_tracker_for_allot_to_sale_order_item)).to be_valid }
    it { expect(create(:regrade_tracker_for_allot_to_material_order_shipment)).to be_valid }
  end
  let(:operations_area_chamber_type) {create(:chamber_type) }
  let(:regrade_tracker_for_regrade) { create(:regrade_tracker_for_regrade) }
  let(:regrade_tracker_for_merge) { create(:regrade_tracker_for_merge) }
  let(:regrade_tracker_for_allot_to_sale_order_item) { create(:regrade_tracker_for_allot_to_sale_order_item) }
  let(:regrade_tracker_for_allot_to_material_order_shipment) { create(:regrade_tracker_for_allot_to_material_order_shipment) }
  let(:packaging_item) { create(:nfi_packaging_item) }

  let(:dc_executive_user) { create(:dc_executive_user) }
  let(:hyd_dc) { create(:hyd_dc) }
  let(:dc_lot_1) { create(:dc_lot, dc: hyd_dc, created_date: 10.days.ago) }
  let(:dc_lot_2) { create(:dc_lot, dc: hyd_dc, created_date: 30.days.ago) }
  let(:pomo) { create(:pomo) }
  let(:sku) { create(:sku, product: pomo, grade: "random") }
  let(:sale_order_item) { create(:soi_pomo) }

  context 'ActiveRecord associations' do
    it { should belong_to(:user) }
    it { should belong_to(:product) }
    it { should belong_to(:dc).optional }
    it { should belong_to(:sale_order_item).optional }

    it { should have_one(:inventory_adjustment) }

    it { should have_many(:regradings) }
    it { should have_many(:input_regradings) }
    it { should have_many(:output_regradings) }

    it { should have_many(:packaging_processes).class_name('Qr::PackagingProcess').with_foreign_key(:regrade_tracker_id)}
  end

  describe "ActiveModel validations" do
    it { should validate_presence_of(:tracker_type) }
    it { should validate_inclusion_of(:tracker_type).in_array(RegradeTracker::TrackerType.all) }
  end

  context "scope test" do
    it "scope" do
      regrade_tracker_params = {
          start_time: 1627881660000,
          end_time: 1627971840000,
          moisture_loss: 5,
          grade_c_weight: 15,
          comments: "Testing Regrade Tracker",
          dc_id: hyd_dc.id,
          user_id: dc_executive_user.id
      }
      lots = {
        input: [{
          id: dc_lot_1.id,
          weight: 30
        }, {
          id: dc_lot_2.id,
          weight: 50
        }],
        output: [{
          weight: 60,
          nfi_packaging_item_id: packaging_item.id,
          description: "Testing",
          lot_type: "new",
          sku_id: sku.id
        }]
      }
      after = DateTime.strptime("1627881660000",'%Q')
      before = DateTime.strptime("1627971840000",'%Q')
      regrade_tracker = RegradeTracker.create_tracker!(regrade_tracker_params, lots)
      expect(RegradeTracker.of_id(regrade_tracker.id)).to eq([regrade_tracker])
      expect(RegradeTracker.of_product(sku.product)).to eq([regrade_tracker])
      expect(RegradeTracker.after(after)).to eq([regrade_tracker])
      expect(RegradeTracker.before(before)).to eq([regrade_tracker])
      expect(RegradeTracker.top_grade_c_regrade(100, 1)).to eq([regrade_tracker])
      expect(RegradeTracker.top_moisture_loss_regrade(100, 1)).to eq([regrade_tracker])
    end
  end

  context "model methods test" do
    it "create_tracker" do
      regrade_tracker_params = {
          start_time: 1627881660000,
          end_time: 1627971840000,
          moisture_loss: 5,
          grade_c_weight: 15,
          comments: "Testing Regrade Tracker",
          dc_id: hyd_dc.id,
          user_id: dc_executive_user.id
      }
      lots = {
        input: [{
          id: dc_lot_1.id,
          weight: 30
        }, {
          id: dc_lot_2.id,
          weight: 50
        }],
        output: [{
          weight: 60,
          nfi_packaging_item_id: packaging_item.id,
          description: "Testing",
          lot_type: "new",
          sku_id: sku.id
        }]
      }

      regrade_tracker = RegradeTracker.create_tracker!(regrade_tracker_params, lots)
      expect(regrade_tracker).to be_valid

      input_regradings = regrade_tracker.input_regradings
      output_regradings = regrade_tracker.output_regradings

      input_weight_sum = input_regradings.pluck(:weight).sum
      output_weight_sum = output_regradings.pluck(:weight).sum + regrade_tracker.moisture_loss.to_f
      expect(input_weight_sum).to eq(output_weight_sum)

    end

    it "create_tracker" do
      regrade_tracker_params = {
          start_time: 1627881660000,
          end_time: 1627971840000,
          moisture_loss: 0,
          grade_c_weight: 0,
          comments: "Testing Regrade Tracker",
          dc_id: hyd_dc.id,
          user_id: dc_executive_user.id
      }
      lots = {
        input: [{
          id: dc_lot_1.id,
          weight: 50
        }, {
          id: dc_lot_2.id,
          weight: 50
        }],
        output: [{
          weight: 100,
          nfi_packaging_item_id: packaging_item.id,
          description: "Testing",
          lot_type: "new",
          sku_id: sku.id
        }]
      }

      regrade_tracker = RegradeTracker.create_tracker!(regrade_tracker_params, lots)
      expect(regrade_tracker).to be_valid

      input_regradings = regrade_tracker.input_regradings
      output_regradings = regrade_tracker.output_regradings

      input_weight_sum = input_regradings.pluck(:weight).sum
      output_weight_sum = output_regradings.pluck(:weight).sum + regrade_tracker.moisture_loss.to_f
      expect(input_weight_sum).to eq(output_weight_sum)

      outpu_lot = regrade_tracker.output_lots.first
      date_diff = (Time.now - outpu_lot.created_date) / 1.day
      expect(date_diff).to be_within(0.01).of(20)
      expect(regrade_tracker.input_quantity).to eq(input_weight_sum)
      expect(regrade_tracker.output_quantity).to eq(output_weight_sum)
      expect(regrade_tracker.input_rank_calculation).to eq(0)
      expect(regrade_tracker.output_rank_calculation).to eq(1)
    end

    it "merge_lots" do
      regrade_tracker_params =  {
		    lot_ids: dc_lot_1.id.to_s + "," + dc_lot_2.id.to_s,
        user_id: dc_executive_user.id
      }

      regrade_tracker = RegradeTracker.merge_lots!(regrade_tracker_params)
      expect(regrade_tracker).to be_valid

      input_regradings = regrade_tracker.input_regradings
      output_regradings = regrade_tracker.output_regradings

      input_weight_sum = input_regradings.pluck(:weight).sum
      output_weight_sum = output_regradings.pluck(:weight).sum + regrade_tracker.moisture_loss.to_f
      expect(input_weight_sum).to eq(output_weight_sum)
    end

    it "allot" do
      regrade_tracker_params = {
        tracker_type: RegradeTracker::TrackerType::AllotToSaleOrderItem,
        sale_order_item_id: sale_order_item.id,
        user_id: sale_order_item.sale_order.user_id,
        lots: [{
            id: dc_lot_1.id,
            weight: 20
          },
          {
            id: dc_lot_2.id,
            weight: 40
          }],
        output_lot: {
            sku_id: sale_order_item.sku_id,
            description: "Allotment for Sale order Item #{sale_order_item.id}"
          }
      }

      output_regrading_entry = RegradeTracker.allot!(regrade_tracker_params)
      expect(output_regrading_entry).to be_valid
      
      expect(output_regrading_entry.weight).to eq(60)
      expect(output_regrading_entry.lot.sku_id).to eq(sale_order_item.sku_id)

      regrade_tracker = output_regrading_entry.regrade_tracker
      expect(regrade_tracker).to be_valid

      input_regradings = regrade_tracker.input_regradings
      output_regradings = regrade_tracker.output_regradings

      input_weight_sum = input_regradings.pluck(:weight).sum
      output_weight_sum = output_regradings.pluck(:weight).sum + regrade_tracker.moisture_loss.to_f
      expect(input_weight_sum).to eq(output_weight_sum)
    end

    it "get_dc" do
      expect(regrade_tracker_for_regrade.get_dc.name).to eq(hyd_dc.name)
      expect(regrade_tracker_for_merge.get_dc.name).to eq(hyd_dc.name)
      expect(regrade_tracker_for_allot_to_sale_order_item.get_dc.name).to eq(hyd_dc.name)      
    end

    it "move inventory" do
      oa_chamber_type = create :chamber_type
      zone_chamber_type = create :zone
      operations_area = Chamber.new.dc_primary_chamber(hyd_dc.id)
      dc_lot = create(:dc_lot, dc: hyd_dc, created_date: 10.days.ago, chamber: operations_area)
      zone = create :zone_chamber, dc: hyd_dc, chamber_type: zone_chamber_type
      regrade_tracker_params = {
        start_time: 1627881660000,
        end_time: 1627971840000,
        moisture_loss: 0,
        grade_c_weight: 0,
        comments: "Testing move inventory",
        dc_id: hyd_dc.id,
        user_id: dc_executive_user.id
      }
      lots = {
        input: [{
          id: dc_lot.id,
          weight: 30,
          chamber_id: operations_area.id
        }],
        output: [{
          weight: 30,
          sku_id: sku.id,
          chamber_id: zone.id,
          nfi_packaging_item_id: packaging_item.id,
          sku: {
            grade: "200++"
          }
        }]
      }

      regrade_tracker = RegradeTracker.create_tracker!(regrade_tracker_params, lots)
      zone_chamber_lot= regrade_tracker.output_lots.first
      expect(regrade_tracker.tracker_type).to eq(RegradeTracker::TrackerType::MoveInventory)
      expect(zone_chamber_lot.chamber_id).to eq(zone.id)

      regrade_tracker_params = {
        start_time: 1627881660000,
        end_time: 1627971840000,
        moisture_loss: 0,
        grade_c_weight: 30,
        comments: "Testing move inventory",
        dc_id: hyd_dc.id,
        user_id: dc_executive_user.id,
        to_primary_chamber: true
      }
      lots = {
        input: [{
          id: zone_chamber_lot.id,
          weight: 30,
          chamber_id: zone.id
        }],
        output: []
      }
      regrade_tracker = RegradeTracker.create_tracker!(regrade_tracker_params, lots)
      expect(regrade_tracker.tracker_type).to eq(RegradeTracker::TrackerType::REGRADE)
      expect(regrade_tracker.output_lots.first.chamber_id).to eq(operations_area.id)
    end

  end

end
