# == Schema Information
#
# Table name: payment_request_shipments
#
#  id                 :bigint           not null, primary key
#  payment_request_id :bigint           not null
#  shipment_id        :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe PaymentRequestShipment, type: :model do
  context "valid factory test" do 
    # it { expect(create(:payment_request_shipment)).to be_valid }
  end

  # let(:payment_request_shipment) { create(:payment_request_shipment) }

  describe "ActiveModel validations" do
    # Basic validations
    # it { should validate_uniqueness_of(:shipment_id).case_insensitive }
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:payment_request) }
    it { should belong_to(:shipment) }
  end

end
