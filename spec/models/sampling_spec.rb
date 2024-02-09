# == Schema Information
#
# Table name: samplings
#
#  id             :bigint           not null, primary key
#  user_id        :bigint
#  sampling_time  :datetime
#  lot_id         :bigint
#  weights        :string(255)
#  partial_weight :float(24)
#  average_weight :float(24)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'rails_helper'

RSpec.describe Sampling, type: :model do
  context "valid factory test" do 
    it { expect(FactoryBot.build(:sampling)).to be_valid }
  end

  let(:dc_lot_with_parent_lot_and_partial) { create(:dc_lot_with_parent_lot_and_partial) }
  let(:sampling) { create(:sampling, lot:dc_lot_with_parent_lot_and_partial, partial_weight: 4.5, average_weight: [8,9]) }

  describe "ActiveModel validations" do
    # Basic validations
    it { should validate_numericality_of(:average_weight).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:partial_weight).is_greater_than_or_equal_to(0).allow_nil }
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:lot) }
    it { should belong_to(:user).optional }
  end
  
end
