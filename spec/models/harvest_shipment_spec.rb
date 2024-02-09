# == Schema Information
#
# Table name: harvest_shipments
#
#  id          :bigint           not null, primary key
#  harvest_id  :bigint           not null
#  shipment_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe HarvestShipment, type: :model do
  it "has a valid factory" do
    expect(build(:harvest_shipment)).to be_valid
  end
  
  let(:harvest_shipment) { build(:harvest_shipment) }

  describe "ActiveRecord associations" do
    it { should belong_to(:harvest) }
    it { should belong_to(:shipment) }
  end

end
