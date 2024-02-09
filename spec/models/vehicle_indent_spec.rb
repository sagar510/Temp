# == Schema Information
#
# Table name: vehicle_indents
#
#  id                          :bigint           not null, primary key
#  shipment_id                 :bigint
#  expected_loading_time       :datetime
#  expected_delivery_time      :datetime
#  comments                    :text
#  indent_created_time         :datetime
#

require 'rails_helper'

RSpec.describe Shipment, type: :model do
  context 'factory validation tests' do
    it "has a valid factory" do
      expect(FactoryBot.build(:vehicle_indent)).to be_valid
    end
  end

  context 'validation test' do
    it 'checks if shipment has trip' do
      vehicle_indent =  create :vehicle_indent
      expect { vehicle_indent.update(expected_loading_time: DateTime.now) }.not_to raise_error
      pickup = create :pickup
      trip = create :trip, pickups: [pickup]

      vehicle_indent.shipment.update(pickup_id: trip.pickups.first.id)
      expect { vehicle_indent.update(expected_loading_time: DateTime.now) }.to raise_error(RuntimeError, "Shipment already has a Trip.")
    end
  end
end