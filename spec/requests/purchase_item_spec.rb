require 'rails_helper'

RSpec.describe "PurchaseItems", type: :request do

  context "GET purchase_items#index" do
    login_admin
    
    let(:po) { create(:farmer_purchase_order) }

    it "should get index" do
      get "/purchase_orders/#{po.id}/purchase_items.json"
      expect(response).to have_http_status(200)
    end
  end

end