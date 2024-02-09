require 'rails_helper'

RSpec.describe "Leads", type: :request do

  context 'get call for active leads' do
    before(:each) do
      @ka_ac_1 = FactoryBot.create(:ka_ac_1)
      @ka_cl_1 = FactoryBot.create(:ka_cl_1)
      @mh_ac_1 = FactoryBot.create(:mh_ac_1)
      @mh_cl_1 = FactoryBot.create(:mh_cl_1)
    end

    describe "GET #leads for admins" do
      login_admin

      it "returns http success" do
        get leads_path()
        expect(response).to have_http_status(:success)
      end

      it "get active leads for admin" do
        get leads_path()

        expect(@controller.view_assigns['tab']).to eq(TabConstants::LEADS)
        expect(@controller.view_assigns['subtab']).to eq("active")
        expect(@controller.view_assigns['active_leads']).to eq(2)
        expect(@controller.view_assigns['closed_leads']).to eq(2)
      end

      it "get closed leads for admin" do
        get leads_path(subtab: "closed")

        expect(@controller.view_assigns['tab']).to eq(TabConstants::LEADS)
        expect(@controller.view_assigns['subtab']).to eq("closed")
        expect(@controller.view_assigns['active_leads']).to eq(2)
        expect(@controller.view_assigns['closed_leads']).to eq(2)
      end
    end

    describe "GET #leads for call center executive" do
      login_cce

      it "returns http success" do
        get leads_path()
        expect(response).to have_http_status(:success)
      end

      it "get active leads for cce" do
        get leads_path()

        expect(@controller.view_assigns['tab']).to eq(TabConstants::LEADS)
        expect(@controller.view_assigns['subtab']).to eq("active")
        expect(@controller.view_assigns['active_leads']).to eq(1)
        expect(@controller.view_assigns['closed_leads']).to eq(1)
      end

      it "get closed leads for cce" do
        get leads_path(subtab: "closed")

        expect(@controller.view_assigns['tab']).to eq(TabConstants::LEADS)
        expect(@controller.view_assigns['subtab']).to eq("closed")
        expect(@controller.view_assigns['active_leads']).to eq(1)
        expect(@controller.view_assigns['closed_leads']).to eq(1)
      end
    end

    describe "GET #new for call center executive" do
      before(:each) do
        @user = FactoryBot.create(:farmer_engagement_executive_user)
        @user.state = "Maharashtra"
        @user.save!
        sign_in @user
        @partner = FactoryBot.create(:farmer)
      end
      

      it "returns http success and right tab and phone_number" do
        get new_lead_path(phone_number: "123456789")
        expect(response).to have_http_status(:success)

        expect(@controller.view_assigns['tab']).to eq(TabConstants::LEADS)
        expect(@controller.view_assigns['phone_number']).to eq("123456789")
      end

      it "get form for brand new lead & partner" do
        get new_lead_path(phone_number: "123456789")

        expect(@controller.view_assigns['lead'].new_record?).to eq(true)
        expect(@controller.view_assigns['lead'].state).to eq("Maharashtra")
        expect(@controller.view_assigns['lead'].cc_exec).to eq(@user)
        expect(@controller.view_assigns['lead'].phone_number).to eq("123456789")


        expect(@controller.view_assigns['partner'].new_record?).to eq(true)
        expect(@controller.view_assigns['partner'].phone_number).to eq("123456789")
        expect(@controller.view_assigns['partner'].role).to eq(Partner::Role::FARMER)
      end

      it "get form for new lead & old partner" do
        get new_lead_path(phone_number: @partner.phone_number)

        expect(@controller.view_assigns['lead'].new_record?).to eq(true)
        expect(@controller.view_assigns['lead'].state).to eq("Maharashtra")
        expect(@controller.view_assigns['lead'].cc_exec).to eq(@user)
        expect(@controller.view_assigns['lead'].phone_number).to eq(@partner.phone_number)


        expect(@controller.view_assigns['partner'].new_record?).to eq(false)
        expect(@controller.view_assigns['partner']).to eq(@partner)
      end

      it "get form for old lead & old partner" do
        @ka_ac_1.phone_number = @partner.phone_number
        @ka_ac_1.save!

        get new_lead_path(phone_number: @ka_ac_1.phone_number)

        expect(@controller.view_assigns['lead'].new_record?).to eq(false)
        expect(@controller.view_assigns['lead'].state).to eq("Karnataka")
        expect(@controller.view_assigns['lead']).to eq(@ka_ac_1)


        expect(@controller.view_assigns['partner'].new_record?).to eq(false)
        expect(@controller.view_assigns['partner']).to eq(@partner)
      end
    end

    describe "GET #edit for call center executive" do
      before(:each) do
        @user = FactoryBot.create(:farmer_engagement_executive_user)
        @user.state = "Maharashtra"
        @user.save!
        sign_in @user
        @partner = FactoryBot.create(:farmer)
      end
      

      it "returns http success and right tab and phone_number" do
        get edit_lead_path(@ka_ac_1)
        expect(response).to have_http_status(:success)

        expect(@controller.view_assigns['tab']).to eq(TabConstants::LEADS)
        expect(@controller.view_assigns['phone_number']).to eq(@ka_ac_1.phone_number)
      end

      it "get form for edit lead" do
        @ka_ac_1.phone_number = @partner.phone_number
        @ka_ac_1.save!

        get edit_lead_path(@ka_ac_1)

        expect(@controller.view_assigns['lead'].new_record?).to eq(false)
        expect(@controller.view_assigns['lead'].state).to eq("Karnataka")
        expect(@controller.view_assigns['lead']).to eq(@ka_ac_1)


        expect(@controller.view_assigns['partner'].new_record?).to eq(false)
        expect(@controller.view_assigns['partner']).to eq(@partner)
      end
    end


  end

end
