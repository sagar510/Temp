# == Schema Information
#
# Table name: payment_request_approvers
#
#  id                 :bigint           not null, primary key
#  payment_request_id :bigint           not null
#  user_id            :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe PaymentRequestApprover, type: :model do
  context "valid factory test" do 
    # it { expect(create(:payment_request_approver)).to be_valid }
  end

  # let(:payment_request_approver) { create(:payment_request_approver) }

  describe "ActiveModel validations" do
    # Basic validations
    # it { should validate_uniqueness_of(:user_id).scoped_to(:payment_request_id) }
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:payment_request) }
    it { should belong_to(:approver) }
  end

end
