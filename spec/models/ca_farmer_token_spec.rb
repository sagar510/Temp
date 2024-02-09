require 'rails_helper'

RSpec.describe CaFarmerToken, type: :model do
  let(:dc) { create(:dc, dc_type: Dc::Type::CC) }
  let(:ca_gatein) { create(:ca_gatein, dc: dc) }
  let(:farmer) { create(:farmer) }
  let(:ca_gatein_farmer1) { create(:ca_gatein_farmer, ca_gatein: ca_gatein, farmer: farmer) }
  let(:ca_gatein_farmer2) { create(:ca_gatein_farmer, ca_gatein: ca_gatein, farmer: farmer) }
  let(:user) { create(:user) }
  let(:purchase_order) { create(:direct_purchase_order) }
  let(:bill_po_payment_request) { create(:bill_po_payment_request) }
  let(:buyer_approver_user) { create(:buyer_approver_user) }
  let(:finance_approver_user) { create(:finance_approver_user) }
  let(:treasury_user) { create(:treasury_user) }
  let(:product) { create(:pomo) }
  let(:sku) { create(:sku_pomo) }

  describe 'associations' do
    it { should belong_to(:ca_gatein_farmer) }
    it { should belong_to(:cancelled_by).class_name('User').optional }
    it { should belong_to(:purchase_order).optional }
    it { should belong_to(:dc) }
    it { should have_one(:ca_gatein).through(:ca_gatein_farmer) }
    it { should have_many(:products).through(:ca_gatein_farmer) }
    it { should have_many(:ca_gatein_items).through(:ca_gatein_farmer) }
    it { should have_many(:ca_gatein_graded_lots).through(:ca_gatein_farmer) }
    it { should have_many(:payment_requests).through(:purchase_order) }
  end

  describe 'validations' do
    it { should validate_presence_of(:token) }
  end

  describe 'callbacks' do
    context 'before_create' do
      it 'validates token uniqueness' do
        existing_token = create(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, dc: dc)
        farmer_token = build(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer2, dc: dc, token: existing_token.token)
        expect { farmer_token.save }.to raise_error("Token already used")
      end
    end

    context 'before_save' do
      it 'validates DC type' do
        farmer_token = build(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, dc: create(:dc, dc_type: Dc::Type::DC))
        expect { farmer_token.save }.to raise_error("Only PHs are allowed for ca tokens")
      end
    end

    context 'before_update' do
      it 'validates cancellation policies' do
        farmer_token = create(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, dc: dc)
        farmer_token.is_cancelled = true
        expect { farmer_token.save }.to raise_error("cancellation reason must be provided when cancelled")
      end
    end
  end

  describe 'methods' do
    describe '.generate_token' do
      it 'generates a valid token' do
        date = Time.zone.local(2023, 10, 5)
        expect(CaFarmerToken.generate_token(dc.id, CaGatein::InwardType::CRATES, date)).to eq("C-2310-1")
      end
    end

    describe '.get_next_token_number' do
      it 'gets the next token number' do
        create(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, dc: dc, token: "C-2310-1")
        expect(CaFarmerToken.get_next_token_number(dc.id, "C-2310")).to eq(2)
      end
    end

    describe '#is_not_graded?' do
      it 'returns true if there are TO_BE_GRADED items' do
        create(:ca_gatein_item, ca_gatein: ca_gatein, ca_gatein_farmer: ca_gatein_farmer1, status: CaGateinItem::Status::TO_BE_GRADED)
        farmer_token = create(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, dc: dc)
        expect(farmer_token.is_not_graded?).to be_truthy
      end

      it 'returns false if all items are GRADED' do
        create(:ca_gatein_item, ca_gatein: ca_gatein, ca_gatein_farmer: ca_gatein_farmer1, status: CaGateinItem::Status::GRADED)
        farmer_token = create(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, dc: dc)
        expect(farmer_token.is_not_graded?).to be_falsey
      end
    end

    describe '#status' do
      it 'returns the correct status' do
        farmer_token = create(:ca_farmer_token, ca_gatein_farmer: ca_gatein_farmer1, is_cancelled: false, purchase_order: nil, dc: dc)
        item = create(:ca_gatein_item, ca_gatein: ca_gatein, ca_gatein_farmer: ca_gatein_farmer1, status: CaGateinItem::Status::TO_BE_GRADED)
        expect(farmer_token.status).to eq(CaFarmerToken::Status::TO_BE_GRADED)

        farmer_token.ca_gatein_items.each do |item|
          item.update(status: CaGateinItem::Status::GRADED)
        end
        expect(farmer_token.status).to eq(CaFarmerToken::Status::GRADED)

        farmer_token.update(is_cancelled: true, cancellation_reason: "Some reason")
        expect(farmer_token.status).to eq(CaFarmerToken::Status::CANCELLED)
        
        farmer_token.update(is_cancelled: false, cancellation_reason: nil)
        farmer_token.update(purchase_order: purchase_order)
        expect(farmer_token.status).to eq(CaFarmerToken::Status::PO_CREATED)

        farmer_token.update(purchase_order: bill_po_payment_request.purchase_order)
        farmer_token.purchase_order.reload
        expect(farmer_token.status).to eq(CaFarmerToken::Status::BILL_PR_RAISED)

        bill_po_payment_request.update!(status: PaymentRequest::Status::APPROVED, approver_id: buyer_approver_user.id, approved_date: Time.now)
        bill_po_payment_request.update!(status: PaymentRequest::Status::FINANCE_APPROVED, finance_approver_id: finance_approver_user.id, finance_approved_date: Time.now)
        bill_po_payment_request.update!(status: PaymentRequest::Status::PAID, payer_id: treasury_user.id, paid_date: Time.now)
        farmer_token.purchase_order.reload
        expect(farmer_token.status).to eq(CaFarmerToken::Status::BILL_PR_PAID)
      end
    end
  end
end
