require 'rails_helper'
require_relative '../support/devise'

RSpec.describe ContactActivitiesController, type: :request do

  describe "GET #Received Call report" do
    login_admin

    it "returns http success" do
      get report_contact_activities_path()
      expect(response).to have_http_status(:success)
    end

    it "sets right start and end dates" do
      get report_contact_activities_path()

      expect(@controller.view_assigns['tab']).to eq(TabConstants::CALL_LOGS_REPORT)
      expect(@controller.view_assigns['subtab']).to eq(TabConstants::CallLogReports::RECEIVED_CALL)
      expect(@controller.view_assigns['start_date']).to eq((Date.today-3).strftime("%Y-%m-%d %H:%M:%S"))
      expect(@controller.view_assigns['end_date']).to eq(Date.today.end_of_day.strftime("%Y-%m-%d %H:%M:%S"))
    end
  end

  describe "GET #Agent Call report" do
    login_admin

    it "returns http success" do
      get report_contact_activities_path(subtab: TabConstants::CallLogReports::AGENT)
      expect(response).to have_http_status(:success)
    end

    it "sets right start and end dates" do
      get report_contact_activities_path(subtab: TabConstants::CallLogReports::AGENT)

      expect(@controller.view_assigns['tab']).to eq(TabConstants::CALL_LOGS_REPORT)
      expect(@controller.view_assigns['subtab']).to eq(TabConstants::CallLogReports::AGENT)
      expect(@controller.view_assigns['start_date']).to eq(Date.today.strftime("%Y-%m-%d %H:%M:%S"))
      expect(@controller.view_assigns['end_date']).to eq(Date.today.end_of_day.strftime("%Y-%m-%d %H:%M:%S"))
    end
  end

end
