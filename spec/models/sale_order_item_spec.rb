# == Schema Information
#
# Table name: sale_order_items
#
#  id                :bigint           not null, primary key
#  lot_id            :bigint
#  sale_order_id     :bigint           not null
#  ordered_weight    :float(24)
#  dispatched_weight :float(24)
#  grn_weight        :float(24)
#  return_weight     :float(24)
#  gap_weight        :float(24)
#  price             :float(24)
#  dispatched_crates :integer
#  received_crates   :integer
#  sku_id            :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  description       :text(65535)
#  return_lot_id     :bigint
#  return_time       :datetime
#  has_complaints    :boolean          default(FALSE)
#  expected_price    :float(24)        default(0.0)
#  discount          :float(24)
#  reason            :string(255)
#  target_price    :float(24)        default(0.0)
#  discount_type     :varchar(255)
#  discount_reason   :varchar(255)
#
require 'rails_helper'

RSpec.describe SaleOrderItem, type: :model do
  let(:soi) { create(:soi_pomo) }
  before(:all) do
    create(:dc_cdc)
  end
  context 'validation tests' do
    it "has a valid factory" do
      expect(FactoryBot.build(:soi_pomo)).to be_valid
    end
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:sale_order).without_validating_presence }
    it { should belong_to(:sku).without_validating_presence }
    it { should belong_to(:lot).without_validating_presence }
    it { should belong_to(:return_lot).without_validating_presence }

    it { should have_one(:regrade_tracker) }
    it { should have_one(:inventory_adjustment) }

    it { should have_many(:returns) }
    it { should have_many(:complaints) }
    it { should have_many(:quality_issues) }
  end

  context 'method tests' do
    it "update_complaints" do
      soi = create(:soi_pomo)
      quality_issue = create(:quality_issue)
      params = {}
      params[:has_complaints] = true
      params[:complaints] = []
      params[:complaints][0] = {}
      params[:complaints][0][:sale_order_item_id] = soi.id
      params[:complaints][0][:quality_issue_id] = quality_issue.id
      expect(soi.update!(params.except(:complaints))).to eq(true)
      soi.update_complaints(params)
      expect(soi.complaints.count).to eq(1)
      expect(soi.complaints.first.quality_issue_id).to eq(quality_issue.id)
    end

    it "total_target_price" do
      soi = create :soi_pomo
      expect(soi.total_target_price).to eq(0)
      soi.update(dispatched_weight: 10)
      soi.update(target_price: 15)
      expect(soi.total_target_price).to eq(150)
    end

    it "flag_moi" do
      soi = create :soi_with_moi_for_amo
      expect(soi.material_order_items.all? {|moi| moi[:soi_edited] == true}).to eq(false)
      soi.update!(ordered_weight: 11)
      expect(soi.material_order_items.all? {|moi| moi[:soi_edited] == true}).to eq(true)
    end

    it "price_per_kg" do
      soi = create :cso_soi_pomo
      expect(soi.price_per_kg).to eq(15)
      soi.update(average_weight: 15)
      soi.update(sale_unit: 2)
      expect(soi.price_per_kg).to eq(1)
    end

    it "target_price_per_kg" do
      soi = create :cso_soi_pomo
      expect(soi.target_price_per_kg).to eq(15)
      soi.update(average_weight: 15)
      soi.update(sale_unit: 2)
      expect(soi.target_price_per_kg).to eq(1)
    end

    it "kgs_sale?" do
      soi = create :cso_soi_pomo
      expect(soi.kgs_sale?).to eq(true)
      soi.update(sale_unit: 2)
      expect(soi.kgs_sale?).to eq(false)
    end

    it "units_sale?" do
      soi = create :cso_soi_pomo
      expect(soi.units_sale?).to eq(false)
      soi.update(sale_unit: 2)
      expect(soi.units_sale?).to eq(true)
    end

    it "grn_quantity_in_unit?" do
      soi = create :cso_soi_pomo
      expect(soi.grn_quantity_in_unit).to eq(0)
      soi.update(average_weight: 20)
      expect(soi.grn_quantity_in_unit).to eq(0)
      soi.update(grn_weight: 200)
      expect(soi.grn_quantity_in_unit).to eq(10)
      soi.update(average_weight: 0)
      expect(soi.grn_quantity_in_unit).to eq(0)
      soi.update(average_weight: -10)
      expect(soi.grn_quantity_in_unit).to eq(-20)
      soi.update(grn_weight: -200)
      expect(soi.grn_quantity_in_unit).to eq(20)
  end
end  

  context 'callback tests' do

    it "can_not_change_sku_after_allotment" do
      soi1 = create(:soi_pomo)
      reg_track = create :regrade_tracker_for_allot_to_sale_order_item, sale_order_item: soi1
      pomo_sb_sku = create(:sku_pomo_sb)
      expect { soi1.update!(sku_id: pomo_sb_sku.id) }.to raise_error
    end

    it "destroy_all_complaints_if_has_complaints_flag_turned_false" do
      soi = create(:soi_pomo)
      quality_issue = create(:quality_issue)
      params = {}
      params[:has_complaints] = true
      params[:complaints] = []
      params[:complaints][0] = {}
      params[:complaints][0][:sale_order_item_id] = soi.id
      params[:complaints][0][:quality_issue_id] = quality_issue.id
      soi.update!(params.except(:complaints))
      soi.update_complaints(params)
      soi.update!(has_complaints: false)
      expect(soi.complaints.count).to eq(0)
    end

    it "discounttype_should_be_present_if_discount" do
      soi = create :soi_pomo
      expect { soi.update!(price: 14, discount_type: nil) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Discount type is required if discount is given")
      expect { soi.update(price: 15, discount_type: nil) }.not_to raise_error
      expect { soi.update(price: 15, target_price: nil, discount_type: nil) }.not_to raise_error
      expect { soi.update(price: 16, discount_type: nil) }.not_to raise_error
      expect { soi.update(price: 14, target_price: 15, discount_type: 'Others') }.not_to raise_error
    end
  end

end
