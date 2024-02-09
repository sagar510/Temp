# == Schema Information
#
# Table name: pickups
#
#  id                    :bigint           not null, primary key
#  trip_id               :bigint
#  vehicle_arrival_time  :datetime
#  vehicle_dispatch_time :datetime
#  is_driver_present     :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  loading_details_json  :json
#  pickup_order          :integer
#  gross_weight          :float(24)
#  tare_weight           :float(24)
#
require 'rails_helper'

RSpec.describe Pickup, type: :model do
  context "factory validations" do
    it "has a valid factory" do
      expect(FactoryBot.build(:pickup)).to be_valid
    end
  end

  context "association tests" do
    it "has_many shipments" do
      should have_many(:shipments)
    end
  end

  context "after save test" do
    it "will nullify shipments before pickup destroy" do
      pickup = create(:pickup)
      shipment = create :dc_to_dc_shipment, pickup: pickup
      pickup.destroy!
      shipment.reload
      expect(shipment.pickup).to eq(nil)
    end
  end
end
