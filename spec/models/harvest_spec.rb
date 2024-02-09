# == Schema Information
#
# Table name: harvests
#
#  id                               :bigint           not null, primary key
#  identifier                       :string(255)
#  purchase_order_id                :bigint
#  misc_packaging_materials_json    :json
#  packaging_details_json           :json
#  status                           :string(255)
#  harvest_date                     :date
#  harvesting_details_json          :json
#  average_packed_box_weight_in_kgs :float(24)
#  average_katran_weight_in_kgs     :float(24)
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  check_list_json                  :json
#  harvest_day                      :integer          not null
#  shipments_map_json               :json
#  grader_id                        :bigint
#
require 'rails_helper'
require_relative '../support/devise'

RSpec.describe Harvest, type: :model do

  context "valid factory test" do 
    it {expect(create(:child_harvest)).to be_valid }
  end

  let(:purchase_order) { create(:farmer_purchase_order) }
  let(:harvest) {purchase_order.harvests.first}
  let(:child_harvest) { create(:child_harvest) }

  describe "ActiveModel validations" do
    # Basic validations
    it { expect(harvest).to validate_inclusion_of(:status).in_array(Harvest::Status.all) }
    it { expect(harvest).to validate_uniqueness_of(:harvest_date).scoped_to(:purchase_order_id) }
    it { expect(harvest).to validate_uniqueness_of(:harvest_day).scoped_to(:purchase_order_id) }

    it "harvest_date_cannot_be_changed_for_root_harvest" do
      root_harvest = child_harvest.root
      expect { root_harvest.update!(harvest_date: Time.now) }.to raise_error
    end
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:purchase_order) }
    it { should belong_to(:grader).optional }

    it { should have_many(:harvest_shipments) }
    it { should have_many(:shipments) }
    it { should have_many(:lots) }
  end

end
