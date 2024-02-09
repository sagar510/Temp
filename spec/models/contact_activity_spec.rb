# == Schema Information
#
# Table name: contact_activities
#
#  id           :bigint           not null, primary key
#  caller       :string(255)      not null
#  receiver     :string(255)
#  bridgenumber :string(255)      not null
#  kaleyra_id   :string(255)      not null
#  call_type    :string(255)
#  starttime    :datetime
#  endtime      :datetime
#  duration     :integer
#  billsec      :integer
#  circle       :string(255)
#  ivrid        :string(255)
#  status       :string(255)
#  recordpath   :string(255)
#  agentname    :string(255)
#  hangupfirst  :string(255)
#  disposition  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  ext_num      :string(255)
#  user_id      :bigint
#  dtmf         :string(255)
#
require 'rails_helper'

RSpec.describe ContactActivity, type: :model do

  context 'scope and get call hash between dates' do
    before(:each) do
      FactoryBot.create(:ca_o1)
      FactoryBot.create(:ca_o2)
      FactoryBot.create(:ca_o3)
      FactoryBot.create(:ca_o4)
      @ca_i1 = FactoryBot.create(:ca_i1)
      @ca_i2 = FactoryBot.create(:ca_i2)
      @ca_i3 = FactoryBot.create(:ca_i3)
      @ca_i4 = FactoryBot.create(:ca_i4)
      @ca_i5 = FactoryBot.create(:ca_i5)
      @ca_m1 = FactoryBot.create(:ca_m1)
    end

    it "check scope" do
      expect(ContactActivity.of_type(ContactActivity::Type::OUTGOING).size).to eq(4)
      expect(ContactActivity.of_type(ContactActivity::Type::INCOMING).size).to eq(5)
      expect(ContactActivity.of_type(ContactActivity::Type::MISSED)).to eq([@ca_m1])
    end


    it "return right agent report data" do
      sdate = DateTime.new(2020,9,10,10,10,10).strftime("%Y-%m-%d %H:%M:%S")
      edate = DateTime.new(2020,11,10,10,10,10).strftime("%Y-%m-%d %H:%M:%S")
      data = ContactActivity.get_call_hash_between_dates(sdate, edate)

      expect(data.keys).to eq(["Raju", "Ravi"])

      expect(data["Raju"][:outgoing_dailed]).to eq(2)
      expect(data["Ravi"][:outgoing_dailed]).to eq(2)

      expect(data["Raju"][:outgoing_connected]).to eq(1)
      expect(data["Ravi"][:outgoing_connected]).to eq(1)

      expect(data["Raju"][:total_incoming]).to eq(2)
      expect(data["Ravi"][:total_incoming]).to eq(3)

      expect(data["Raju"][:incoming_connected]).to eq(1)
      expect(data["Ravi"][:incoming_connected]).to eq(1)

      expect(data["Raju"][:total_outgoing_talk_time]).to eq(20)
      expect(data["Ravi"][:total_outgoing_talk_time]).to eq(10)

      expect(data["Raju"][:total_incoming_talk_time]).to eq(25)
      expect(data["Ravi"][:total_incoming_talk_time]).to eq(15)

      expect(data["Raju"][:total_time_on_phone]).to eq(75)
      expect(data["Ravi"][:total_time_on_phone]).to eq(55)

      expect(data["Raju"][:total_talk_time]).to eq(45)
      expect(data["Ravi"][:total_talk_time]).to eq(25)
    end

    it "return right received calls data" do
      sdate = DateTime.new(2020,10,8,10,10,10).strftime("%Y-%m-%d %H:%M:%S")
      edate = DateTime.new(2020,10,11,10,10,10).strftime("%Y-%m-%d %H:%M:%S")
      data = ContactActivity.get_received_call_hash_between_dates(sdate, edate)

      dates = [Date.parse("2020-10-8"), Date.parse("2020-10-9"),Date.parse("2020-10-10"),Date.parse("2020-10-11")]

      expect(data.keys).to eq(dates)

      expect(data[dates[0]][:missed]).to eq({})
      expect(data[dates[0]][:incoming]).to eq({})

      expect(data[dates[1]][:missed]).to eq({})
      expect(data[dates[1]][:incoming]).to eq(
        {
          "#{@ca_i2.circle}"=>{:ans=>[], :not_ans=>[], :not_attn=>[@ca_i2.caller], :total=>[@ca_i2.caller]},
          "#{@ca_i3.circle}"=>{:ans=>[@ca_i3.caller], :not_ans=>[], :not_attn=>[], :total=>[@ca_i3.caller]}
        }
      )

      expect(data[dates[2]][:missed]).to eq({})
      expect(data[dates[2]][:incoming]).to eq(
        {
          "#{@ca_i4.circle}"=>{:ans=>[], :not_ans=>[], :not_attn=>[@ca_i4.caller,@ca_i5.caller], :total=>[@ca_i4.caller,@ca_i5.caller]},
          "#{@ca_i1.circle}"=>{:ans=>[@ca_i1.caller], :not_ans=>[], :not_attn=>[], :total=>[@ca_i1.caller]}
        }
      )

      expect(data[dates[3]][:missed]).to eq({"#{@ca_m1.circle}"=>{:ans=>[], :not_ans=>[], :not_attn=>[@ca_m1.caller], :total=>[@ca_m1.caller]}})
      expect(data[dates[3]][:incoming]).to eq({})
    end
  end

end
