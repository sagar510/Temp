require 'rails_helper'
require_relative '../support/devise'

RSpec.describe PurchaseOrdersController, type: :request do

  describe "POST" do
    login_admin
    let(:farmer) { create(:farmer) }
    let(:supplier) { create(:supplier) }
    let(:buyer) { create(:buyer_user) }
    let(:field_executive) { create(:field_executive_user) }
    let(:service_provider) { create(:service_provider) }
    let(:micro_pocket) {create :micro_pocket}
    it 'should create purchase order with a farmer' do
      count = PurchaseOrder.count
      post "/purchase_orders.json", params: {
        purchase_order: {
        address: "Reddiyar Palayam, Pondicherry, India",
        expected_harvest_date: "1597429800000",
        buyer_ids: [buyer.id],
        micro_pocket_id: micro_pocket.id,
        partner_id: farmer.id,
        field_executive_ids: [field_executive.id],
        service_provider_id: service_provider.id
        }
      }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['partner']['role_names']).to eq(Partner::Role::FARMER)
      expect(PurchaseOrder.count).to eq(count + 1)
    end

    it 'should create purchase order with a vendor' do
      count = PurchaseOrder.count
      post "/purchase_orders.json", params: {
        purchase_order: {
        address: "Reddiyar Palayam, Pondicherry, India",
        expected_harvest_date: "1597429800000",
        buyer_ids: [buyer.id],
        micro_pocket_id: micro_pocket.id,
        partner_id: supplier.id,
        field_executive_ids: [field_executive.id],
        service_provider_id: service_provider.id
        }
      }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['partner']['role_names']).to eq(Partner::Role::SUPPLIER)
      expect(PurchaseOrder.count).to eq(count + 1)
    end

    it 'should raise the expected validation error' do
      expect {
        post "/purchase_orders.json", params: {
          purchase_order: {
            address: "Reddiyar Palayam, Pondicherry, India",
            expected_harvest_date: "1597429800000",
            buyer_ids: [buyer.id],
            micro_pocket_id: micro_pocket.id,
            partner_id: service_provider.id,
            field_executive_ids: [field_executive.id],
            service_provider_id: service_provider.id
          }
        }
      }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Partner should have either a farmer or a supplier')
    end

    let(:buyer1)  { create(:buyer_user) }
    let(:field_executive1)  { create(:field_executive_user) }
    it 'should create purchase order with a mulitple buyers and field_executives' do
      post "/purchase_orders.json", params: {
        purchase_order: {
        address: "Reddiyar Palayam, Pondicherry, India",
        expected_harvest_date: "1597429800000",
        buyer_ids: [buyer.id,buyer1.id],
        micro_pocket_id: micro_pocket.id,
        partner_id: supplier.id,
        field_executive_ids: [field_executive.id,field_executive1.id],
        service_provider_id: service_provider.id
        }
      }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['buyers'].count).to eq(2)
      expect(response_parsed['field_executives'].count).to eq(2)
    end
  end
end
