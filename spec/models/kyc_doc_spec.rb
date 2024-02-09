# == Schema Information
#
# Table name: kyc_docs
#
#  id                    :bigint           not null, primary key
#  doc_type              :string(255)
#  status                :string(255)      default("Unverified")
#  identification_number :string(255)
#  partner_id            :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
require 'rails_helper'

RSpec.describe KycDoc, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:kyc_doc)).to be_valid
  end

  context "association tests" do
    it { should belong_to(:partner) }
  end

  describe 'validations' do
    subject { build(:kyc_doc) }

    it { should validate_presence_of(:doc_type) }
    it { should validate_inclusion_of(:doc_type).in_array(KycDoc::DocType::ALL) }
  end

  describe 'callbacks' do
    it 'sets status to unverified before creation' do
      kyc_doc = build(:kyc_doc, status: nil)
      kyc_doc.save
      expect(kyc_doc.status).to eq(KycDoc::Status::UNVERIFIED)
    end
  end
end
