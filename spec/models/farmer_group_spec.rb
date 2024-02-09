# == Schema Information
#
# Table name: farmer_groups
#
#  id                :bigint           not null, primary key
#  whatsapp_group_id :string(255)
#  name              :string(191)
#  description       :string(191)
#  location          :string(255)
#  created_date      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint
#  partner_numbers   :text(65535)
#
require 'rails_helper'
require_relative '../support/devise'


RSpec.describe FarmerGroup, type: :model do
  context 'ActiveRecord associations and validations' do
    it { should belong_to(:product).optional }

    it { should validate_presence_of(:whatsapp_group_id) }
    it { should validate_uniqueness_of(:whatsapp_group_id).case_insensitive }
  end

  context 'create_if_not_present' do
    it 'create_if_not_present' do

      raw_params = {"conversation" => "12345", "conversationname" => "Test"}
      fm = FarmerGroup.create_if_not_present!(raw_params)


      expect(fm.whatsapp_group_id).to eq("12345")
      expect(fm.name).to eq("Test")
      expect(FarmerGroup.count).to eq(1)

      raw_params = {"conversation" => "12345", "conversationname" => "Test123"}
      fm = FarmerGroup.create_if_not_present!(raw_params)
      expect(fm.whatsapp_group_id).to eq("12345")
      expect(fm.name).to eq("Test")
      expect(FarmerGroup.count).to eq(1)
    end
  end

  context 'methods phone numbers' do
    it 'phone numbers' do

      raw_params = {"conversation" => "12345", "conversationname" => "Test"}
      fm = FarmerGroup.create_if_not_present!(raw_params)


      expect(fm.name).to eq("Test")
      expect(FarmerGroup.count).to eq(1)
      expect(fm.phone_numbers).to eq("")
      expect(fm.partner_numbers).to eq([])

      fm.phone_numbers = "9177023915"
      fm.save!

      expect(fm.phone_numbers).to eq("9177023915")
      expect(fm.partner_numbers).to eq(["9177023915"])
    end
  end
end
