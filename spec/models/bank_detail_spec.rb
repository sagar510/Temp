# == Schema Information
#
# Table name: bank_details
#
#  id                    :bigint           not null, primary key
#  account_number        :string(255)
#  ifsc                  :string(255)
#  beneficiary_name      :string(255)
#  status                :string(255)      default("Unverified")
#  partner_id            :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  ext_bank_verification :json
#
require 'rails_helper'

RSpec.describe BankDetail, type: :model do
  context "valid factory test" do 
    it { expect(create(:bank_detail)).to be_valid }
  end

  context "association tests" do
    it { should belong_to(:partner) }
  end

  context "Validation tests" do
    it "account_number lenght should be in range gtom 9 to 18" do
      bank_detail = build :bank_detail, account_number: 4387587
      expect(bank_detail.save).to eq(false)
    end

    it "account_number and account_number_confirmation should match" do
      bank_detail = build :bank_detail, account_number: "4387587988", account_number_confirmation: "3854969812"
      expect(bank_detail.save).to eq(false)
      bank_detail1 = build :bank_detail, account_number: "1234567890", account_number_confirmation: "1234567890"
      expect(bank_detail1.save).to eq(true)
    end

    it "IFSC lenght should 11" do
      account_number = Time.now.to_epoch.to_s
      bank_detail = build :bank_detail, ifsc: 4387587, account_number: account_number, account_number_confirmation: account_number
      expect(bank_detail.save).to eq(false)

      bank_detail1 = create :bank_detail, ifsc: 43875872345
      expect(bank_detail1.save).to eq(true)
    end
  end

  context "Callback test" do
    it "after_create: set_status" do
      bank_detail = create(:bank_detail)
      expect(bank_detail.status).to eq(KycDoc::Status::UNVERIFIED)
    end
  end

  context "methods test" do
    it "check the get_transaction_type" do
      bank_detail = create(:bank_detail)
      expect(bank_detail.get_transaction_type(10)).to eq("IFC")
      expect(bank_detail.get_transaction_type(200001)).to eq("IFC")
      expect(bank_detail.get_transaction_type(500001)).to eq("RTG")
      bank_detail.update!(ifsc: "icic0000001")
      expect(bank_detail.get_transaction_type(2000001)).to eq("WIB")
      bank_detail.update!(ifsc: "ICIC0000001")
      expect(bank_detail.get_transaction_type(2000001)).to eq("WIB")
    end

    it "check the vendor_name" do
      bank_detail = create(:bank_detail)
      expect(bank_detail.vendor_name).to eq(bank_detail.partner.name)
      bank_detail.update!(beneficiary_name: "Test/123/- MBMBMBMBMBMBMBMBMBMBMBMBMBMAAAAAA")
      expect(bank_detail.vendor_name).to eq("Test MBMBMBMBMBMBMBMBMBMBMBMBMBM")      
    end
  end
end
