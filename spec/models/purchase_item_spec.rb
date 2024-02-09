# == Schema Information
#
# Table name: purchase_items
#
#  id                :bigint           not null, primary key
#  identifier        :string(255)
#  name              :string(255)
#  weight_in_kgs     :float(24)        default(0.0)
#  agreed_value      :float(24)
#  purchase_order_id :bigint
#  shipment_id       :bigint
#  parent_id         :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  material_grade    :string(255)
#  description       :text(65535)
#  sku_id            :bigint
#  product_id        :bigint
#  package_type      :string(255)
#  average_weight    :float(24)
#  packaging_type_id :bigint
#
require 'rails_helper'

RSpec.describe PurchaseItem, type: :model do
  context 'factory check' do
    it "has valid factories" do
      expect(FactoryBot.build(:pi_pomo)).to be_valid
      expect(FactoryBot.build(:si_pomo)).to be_valid
      expect(FactoryBot.build(:si_pomo_sb)).to be_valid
    end

    let(:purchaseitem) { create(:pi_pomo) }
    let(:shipmentitem) { create(:si_pomo) }
    it "shipment item should have same name and agreed_value as purchase item" do
      shipmentitem.parent_id = purchaseitem.id
      shipmentitem.save!
      expect(shipmentitem.name).to eq(purchaseitem.name)
      expect(shipmentitem.agreed_value).to eq(purchaseitem.agreed_value)
    end

    it "deviationtype_should_be_present_if_deviation" do
      poi = create :pi_pomo
      expect { poi.update!(agreed_value: 16, target_buying_price: 15, deviation_type: nil) }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Deviation type is required if deviation is given")
      expect { poi.update!(agreed_value: 15, target_buying_price: 15, deviation_type: nil) }.not_to raise_error
      expect { poi.update!(agreed_value: 15, target_buying_price: nil, deviation_type: nil) }.not_to raise_error
      expect { poi.update!(agreed_value: 15, target_buying_price: 16, deviation_type: nil) }.not_to raise_error
      expect { poi.update!(agreed_value: 16, target_buying_price: 15, deviation_type: 'Others') }.not_to raise_error
    end
  end
end
