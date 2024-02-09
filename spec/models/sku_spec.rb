# == Schema Information
#
# Table name: skus
#
#  id          :bigint           not null, primary key
#  grade       :string(255)
#  product_id  :bigint           not null
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  min_weight  :integer          default(0)
#  max_weight  :integer          default(0)
#  count       :integer          default(0)
#  colour      :string(255)
#  active      :boolean          default(TRUE)
#
require 'rails_helper'

RSpec.describe Sku, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:sku_pomo)).to be_valid
    expect(FactoryBot.build(:sku_pomo_sb)).to be_valid
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:product) }
    it { should have_many(:packaging_output_lots).class_name('Qr::PackagingOutputLot').with_foreign_key(:sku_id)}

    it { should validate_numericality_of(:min_weight).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:max_weight).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:count).is_greater_than_or_equal_to(0) }
  end

  context 'scope tests' do
    it 'remove_grade_c' do
      sku1 = create :sku_pomo
      sku2 = create :sku_pomo_sb
      sku3 = create :sku_pomo_grade_c

      expect(Sku.remove_grade_c.include? sku1).to eq(true)
      expect(Sku.remove_grade_c.include? sku2).to eq(true)
      expect(Sku.remove_grade_c.include? sku3).to eq(false)
      expect(Sku.active.include? sku1).to eq(true)
      expect(Sku.active.include? sku2).to eq(true)
    end
    it 'active/suspended' do
      sku1 = create :sku_pomo
      sku2 = create :sku_pomo_inactive
      expect(Sku.active.include? sku1).to eq(true)
      expect(Sku.suspended.include? sku2).to eq(true)
      expect(Sku.active.include? sku2).to eq(false)
      expect(Sku.suspended.include? sku1).to eq(false)
    end

    it 'of_ids' do 
      sku1 = create :sku_pomo
      sku2 = create :sku_pomo_sb
      expect(Sku.of_ids([sku1.id]).include? sku1).to eq(true)
      expect(Sku.of_ids([sku1.id]).include? sku2).to eq(false)
    end

    it 'of_dc_inventory' do 
      dc1 = create :dc
      dc2 = create :dc

      sku1 = create :sku_pomo
      sku2 = create :sku_pomo_sb
      sku3 = create :sku_pomo_grade_c
      lot1 = create :lot, sku: sku1, dc: dc1, current_weight: 1
      lot2 = create :lot, sku: sku2, dc: dc1, current_weight: 1
      lot3 = create :lot, sku: sku3, dc: dc2, current_weight: 1

      expect(Sku.of_dc_inventory(dc1.id).include? sku1).to eq(true)
      expect(Sku.of_dc_inventory(dc1.id).include? sku2).to eq(true)
      expect(Sku.of_dc_inventory(dc1.id).include? sku3).to eq(false)
    end
  end


end
