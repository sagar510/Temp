# == Schema Information
#
# Table name: partners
#
#  id                 :bigint           not null, primary key
#  name               :string(255)
#  role               :string(255)
#  source             :string(255)
#  whatsapp_number    :string(255)
#  phone_number       :string(255)
#  crop_metadata      :text(65535)
#  comments           :text(65535)
#  volume             :float(24)        default(0.0)
#  rejection          :float(24)        default(0.0)
#  transactions       :integer
#  location_id        :bigint
#  creator_id         :integer
#  has_tractor        :boolean          default(FALSE)
#  is_valid_number    :boolean          default(TRUE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  total_land_holding :float(24)
#  engagement_cohort  :integer          default(0)
#  roles_mask         :integer
#  transporter_type   :string(255)
#
require 'rails_helper'

RSpec.describe Partner, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:farmer)).to be_valid
    expect(FactoryBot.build(:supplier)).to be_valid
    expect(FactoryBot.build(:service_provider)).to be_valid
  end

  context 'validation tests' do
    let(:farmer) { create(:farmer) }
    let(:farmer1) { create(:farmer) }

    it 'has unique phone nummer' do
      farmer1.phone_number = farmer.phone_number
      expect(farmer1).to_not be_valid
      expect(farmer1.errors.messages[:phone_number]).to eq ['has already been taken']
    end
  end

  context 'Association tests' do
    it { should have_many(:kyc_docs) }
    it { should have_one(:bank_detail) }
  end

  context "model methods test" do
    let(:multi_role_partner) { create(:multi_role_partner) }

    it "role check methods" do
      expect(multi_role_partner.farmer?).to eq(true)
      expect(multi_role_partner.supplier?).to eq(true)
      expect(multi_role_partner.service_provider?).to eq(false)
    end

    it "role and role_names" do
      expect(multi_role_partner.roles).to eq([Partner::Role::FARMER, Partner::Role::SUPPLIER, Partner::Role::GRADER])
      expect(multi_role_partner.role_names).to eq([Partner::Role::FARMER, Partner::Role::SUPPLIER, Partner::Role::GRADER].join(", "))
    end

    it "update roles" do
      expect(multi_role_partner.roles).to eq([Partner::Role::FARMER, Partner::Role::SUPPLIER, Partner::Role::GRADER])

      multi_role_partner.roles += [Partner::Role::SERVICE_PROVIDER]
      multi_role_partner.save!
      expect(multi_role_partner.roles).to eq([Partner::Role::FARMER, Partner::Role::SUPPLIER, Partner::Role::SERVICE_PROVIDER, Partner::Role::GRADER])

      multi_role_partner.roles = [Partner::Role::FARMER, Partner::Role::SUPPLIER]
      multi_role_partner.save!
      expect(multi_role_partner.roles).to eq([Partner::Role::FARMER, Partner::Role::SUPPLIER])
    end

    it "update kyc status and bank details to unverfied if the name is chagned" do
      partner = create(:farmer)
      kyc_doc = create :kyc_doc, partner: partner
      bank_detail = create :bank_detail, partner: partner
      kyc_doc.update!(status: KycDoc::Status::VERIFIED)

      expect(partner.kyc_status).to eq(Partner::KycStatus::VERIFIED)

      partner.update!(name: "jarvis")

      expect(partner.kyc_status).to eq(Partner::KycStatus::UNVERIFIED)
    end

    it "has_transactions_access?" do
        transporter = create(:transporter)
        farmer = create(:farmer)
        manager = create(:logistics_manager_user)
        field_executive = create(:field_executive_user)
        expect(farmer.has_transactions_access?(manager)).to eq(false)
        expect(farmer.has_transactions_access?(field_executive)).to eq(false)
        expect(transporter.has_transactions_access?(manager)).to eq(true)
        expect(transporter.has_transactions_access?(field_executive)).to eq(false)
    end
  end
end
