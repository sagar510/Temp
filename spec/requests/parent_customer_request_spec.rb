require 'rails_helper'

RSpec.describe "ParentCustomers", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/parent_customer/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/parent_customer/index"
      expect(response).to have_http_status(:success)
    end
  end

end
