# == Schema Information
#
# Table name: farmer_messages
#
#  id                           :bigint           not null, primary key
#  sender                       :string(255)
#  body                         :text(16777215)
#  group_id                     :string(255)
#  sent_at                      :datetime
#  url                          :text(16777215)
#  lat                          :float(24)
#  lng                          :float(24)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :integer
#  harvesting_start_date        :datetime
#  harvesting_end_date          :datetime
#  bacmsgid                     :string(255)
#  repliedbacmsgid              :string(255)
#  dump_id                      :integer
#  farmer_message_collection_id :bigint
#
require 'rails_helper'
require_relative '../support/devise'


RSpec.describe FarmerMessage, type: :model do
  let(:farmer) { create(:farmer) }

  context 'ActiveRecord associations and validations' do
    it { should belong_to(:partner).optional }

    it { should validate_presence_of(:sender) }
    it { should validate_presence_of(:sent_at) }
    it { should validate_presence_of(:dump_id) }
    # it { should validate_uniqueness_of(:dump_id).case_insensitive }
    it { should validate_presence_of(:bacmsgid) }
    # it { should validate_uniqueness_of(:bacmsgid).case_insensitive }
  end

  context 'callback' do
    it 'lat lng being set' do
      expect(farmer.farmer_groups.size).to eq(0)
      farmer.update_column(:phone_number, "9879879870")

      raw_params = {"phone" => farmer.phone_number, "message" => "Hi", "time" => "2021-11-02 13:01:15.PM", "bacmsgid" => "1234sdsd", "conversation" => "1234"}
      fm = FarmerMessage.create_from_raw_params!(raw_params, 1)

      expect(fm.partner).to eq(farmer)
      expect(fm.partner.farmer_groups.size).to eq(0)

      expect(fm.lat).to eq(nil)
      expect(fm.lng).to eq(nil)

      raw_params["message"] = "[location] Location Shared : https://maps.google.com/?q=16.48459243774414,80.68881225585938"
      raw_params["bacmsgid"] = "1234sdsd1"

      fm1 = FarmerMessage.create_from_raw_params!(raw_params, 2)
      expect(fm1.partner).to eq(farmer)
      expect(fm1.lat).to eq(16.48459243774414)
      expect(fm1.lng).to eq(80.68881225585938)

      tag_list = [MessageTag.first().name, MessageTag.second().name]
      disease_list = [Disease.first().name, Disease.second().name]
      start_time = Time.now()
      end_time = Time.now() + 10000
      fm.update!(
        tag_list: tag_list,
        disease_list: disease_list,
        harvesting_start_date: start_time,
        harvesting_end_date: end_time
      )
      expect(fm.tags.pluck(:name)).to eq(tag_list)
      expect(fm.diseases.pluck(:name)).to eq(disease_list)
      expect(fm.harvesting_end_date.to_date).to eq(end_time.to_date)
      expect(fm.harvesting_start_date.to_date).to eq(start_time.to_date)
    end
  end
end
