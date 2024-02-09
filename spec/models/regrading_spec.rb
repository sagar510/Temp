# == Schema Information
#
# Table name: regradings
#
#  id                 :bigint           not null, primary key
#  regrade_tracker_id :bigint           not null
#  lot_id             :bigint           not null
#  weight             :float(24)
#  lot_type           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe Regrading, type: :model do

  context "valid factory test" do 
    it { expect(create(:input_regrading)).to be_valid }
    it { expect(create(:output_regrading)).to be_valid }
  end

  let(:input_regrading) { create(:input_regrading) }
  let(:output_regrading) { create(:output_regrading) }

  context 'ActiveRecord associations' do
    it { should belong_to(:regrade_tracker) }
    it { should belong_to(:lot) }  
  end

  describe "ActiveModel validations" do
    it { should validate_numericality_of(:weight).is_greater_than(0) }    
    it { should validate_inclusion_of(:lot_type).in_array(Regrading::LotType.all) }
  end

  context "model methods test" do
    it "lot_label" do
      expect(input_regrading.lot_label).to eq("DC-LOT/POMO/200-300")
    end
  end

end
