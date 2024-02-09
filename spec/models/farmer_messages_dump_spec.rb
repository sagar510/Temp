# == Schema Information
#
# Table name: farmer_messages_dumps
#
#  id         :bigint           not null, primary key
#  raw_params :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'
require_relative '../support/devise'


RSpec.describe FarmerMessagesDump, type: :model do
  let(:farmer) { create(:farmer) }
  let(:farmer1) { create(:farmer) }
  let(:farmer2) { create(:farmer) }

  context 'ActiveRecord associations and validations' do
    it { should have_one(:farmer_message) }
  end

  context 'create_child_records' do
    it 'creates child records messages' do
      farmer.update_column(:phone_number, "9879879870")

      expect(farmer.farmer_groups.size).to eq(0)

      expect(FarmerMessagesDump.count).to eq(0)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(0)

      raw_params = {
        "phone" => farmer.phone_number,
        "message" => "[location] Location Shared : https://maps.google.com/?q=16.48459243774414,80.68881225585938", 
        "time" => "2021-11-02 13:01:15.PM", 
        "bacmsgid" => "1234sdsd",
        "conversation" => "TG12345",
        "conversationname" => "Test Group",
      }

      f = FarmerMessagesDump.create!(raw_params: raw_params)

      expect(FarmerMessagesDump.count).to eq(1)
      expect(FarmerMessage.count).to eq(1)
      expect(FarmerGroup.count).to eq(1)

      fm = f.farmer_message
      fg = fm.farmer_group

      expect(fm.partner).to eq(farmer)
      expect(fm.partner.farmer_groups).to eq([fg])

      expect(fg.whatsapp_group_id).to eq("TG12345")
      expect(fg.name).to eq("Test Group")
      expect(fg.partner_numbers.size).to eq(1)
    end

    it 'creates child user addition' do
      farmer.update_column(:phone_number, "9879879870")
      farmer1.update_column(:phone_number, "9879879860")
      farmer2.update_column(:phone_number, "9879879850")

      expect(FarmerMessagesDump.count).to eq(0)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(0)

      raw_params = {
        "phone" => farmer.phone_number,
        "message" => "[GroupNotif] +919879879870 Joined by Invitation Link",
        "time" => "2021-11-02 13:01:15.PM", 
        "bacmsgid" => "1234sdsd",
        "conversation" => "TG12345",
        "conversationname" => "Test Group",
      }

      f = FarmerMessagesDump.create!(raw_params: raw_params)

      expect(FarmerMessagesDump.count).to eq(1)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.whatsapp_group_id).to eq("TG12345")
      expect(fg.name).to eq("Test Group")
      expect(fg.partners).to eq([farmer])
      expect(fg.partner_numbers.size).to eq(1)

      raw_params["message"] = "[GroupNotif] +919879879870 Left"

      f = FarmerMessagesDump.create!(raw_params: raw_params)
      expect(FarmerMessagesDump.count).to eq(2)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.whatsapp_group_id).to eq("TG12345")
      expect(fg.name).to eq("Test Group")
      expect(fg.partners).to eq([])
      expect(fg.partner_numbers.size).to eq(0)

      raw_params["message"] = "[GroupNotif] +919177091770 Added +919879879870"

      f = FarmerMessagesDump.create!(raw_params: raw_params)
      expect(FarmerMessagesDump.count).to eq(3)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.whatsapp_group_id).to eq("TG12345")
      expect(fg.name).to eq("Test Group")
      expect(fg.partners).to eq([farmer])
      expect(fg.partner_numbers.size).to eq(1)

      raw_params["message"] = "[GroupNotif] +919177091770 Added 919879879870,919879879860,919879879850"

      f = FarmerMessagesDump.create!(raw_params: raw_params)
      expect(FarmerMessagesDump.count).to eq(4)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.whatsapp_group_id).to eq("TG12345")
      expect(fg.name).to eq("Test Group")
      expect(fg.partners.to_a).to match_array([farmer, farmer1, farmer2])
      expect(fg.partner_numbers.size).to eq(3)

      raw_params["message"] = "[GroupNotif] +919177091770 Removed +919879879870"

      f = FarmerMessagesDump.create!(raw_params: raw_params)
      expect(FarmerMessagesDump.count).to eq(5)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.partners.to_a).to match_array([farmer1, farmer2])
      expect(fg.partner_numbers.size).to eq(2)

      raw_params["message"] = "[GroupNotif] +919177091770 Removed 919879879860,919879879850,"

      f = FarmerMessagesDump.create!(raw_params: raw_params)
      expect(FarmerMessagesDump.count).to eq(6)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.partners).to eq([])
      expect(fg.partner_numbers.size).to eq(0)

      raw_params["message"] = "[GroupNotif] +919177091770 Added 91123456789,91123456788"

      f = FarmerMessagesDump.create!(raw_params: raw_params)
      expect(FarmerMessagesDump.count).to eq(7)
      expect(FarmerMessage.count).to eq(0)
      expect(FarmerGroup.count).to eq(1)

      fg = FarmerGroup.last

      expect(fg.partners).to eq([])
      expect(fg.partner_numbers.size).to eq(2)
    end
  end
end
