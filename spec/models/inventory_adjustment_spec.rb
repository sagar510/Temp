# == Schema Information
#
# Table name: inventory_adjustments
#
#  id                 :bigint           not null, primary key
#  weight             :float(24)
#  reason             :integer
#  source_type        :integer
#  source_id          :bigint
#  date               :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :text(65535)
#  user_id            :bigint
#  dc_id              :bigint
#  sale_order_item_id :bigint
#  regrade_tracker_id :bigint
#  lot_id             :bigint
#  product_id         :bigint
#
require 'rails_helper'

RSpec.describe InventoryAdjustment, type: :model do

  context "valid factory test" do 
    it { expect(create(:customer_gap_inv_adj)).to be_valid }
    it { expect(create(:dump_inv_adj)).to be_valid }
    # it { expect(create(:moisture_loss_inv_adj)).to be_valid }
    it { expect(create(:transit_gap_inv_adj)).to be_valid }
    it { expect(create(:transit_moisture_loss_inv_adj)).to be_valid }
  end

  let(:customer_gap_inv_adj) { create(:customer_gap_inv_adj) }
  let(:dump_inv_adj) { create(:dump_inv_adj) }
  # let(:moisture_loss_inv_adj) { create(:moisture_loss_inv_adj) }
  let(:transit_gap_inv_adj) { create(:transit_gap_inv_adj) }
  let(:transit_moisture_loss_inv_adj) { create(:transit_moisture_loss_inv_adj) }

  describe "ActiveModel validations" do
    # Basic validations
    it { expect(customer_gap_inv_adj).to validate_presence_of(:source_type) }
    it { expect(customer_gap_inv_adj).to validate_presence_of(:reason) }

    it "presence_of_weight_and_date" do
      customer_gap_inv_adj.date = nil
      expect(customer_gap_inv_adj.save).to eq(false)

      customer_gap_inv_adj.date = Time.now
      customer_gap_inv_adj.weight = nil
      expect(customer_gap_inv_adj.save).to eq(false)
    end
  end

end
