# == Schema Information
#
# Table name: payment_requests
#
#  id                   :bigint           not null, primary key
#  created_date         :datetime
#  due_date             :datetime
#  payment_request_type :integer
#  priority             :integer
#  amount               :decimal(12, 3)
#  adjusted_amount      :decimal(12, 3)
#  adjustment_reason    :text(65535)
#  status               :integer
#  creator_id           :bigint
#  comments             :text(65535)
#  purchase_order_id    :bigint
#  trip_id              :bigint
#  zoho_payment_ids     :string(255)
#  zoho_bill_id         :string(255)
#  approver_id          :bigint
#  payer_id             :bigint
#  reject_reason        :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  approved_date        :datetime
#  paid_date            :datetime
#  rejected_date        :datetime
#  rejector_id          :bigint
#  inam_amount          :decimal(12, 3)
#  batch_id             :string(255)
#  dc_id                :bigint
#  vendor_id            :bigint           not null
#  category             :integer          not null
#  per_unit_price       :float(24)
#  start_time           :datetime
#  end_time             :datetime
#  units                :integer
#  bill_number          :string(255)
#  demurrage_amount     :decimal
#  bill_date            :datetime
#  customer_id          :integer
#  zoho_bill_date       :datetime
#  zoho_bill_user_id    :integer
#  is_partial_bill      :boolean
#  parent_bill_id       :integer
#  cost_head_id         :integer
#  agreement_id         :integer
#  vp_id                :string
#  ach_payment              :boolean
#  nfi_purchase_order_id    :integer
#  cash_advance_paid        :float
#  zoho_cash_transaction_id :string
#  farmer_token_id          :integer
#  gatein_id                :integer
#  payment_mode             :integer
#
require 'rails_helper'

RSpec.describe PaymentRequest, type: :model do
  context "valid factory test" do
    it { expect(create(:advance_po_payment_request)).to be_valid }
    it { expect(create(:bill_po_payment_request)).to be_valid }
    it { expect(create(:advance_trip_payment_request)).to be_valid }
    it { expect(create(:advance_nfi_trip_payment_request)).to be_valid }
    it { expect(create(:bill_trip_payment_request)).to be_valid }
    it { expect(create(:bill_nfi_trip_payment_request)).to be_valid }
    it { expect(create(:advance_dc_payment_request)).to be_valid }
    it { expect(create(:bill_dc_payment_request)).to be_valid }
    it { expect(create(:per_unit_bill_dc_payment_request)).to be_valid }
    it { expect(create(:advance_nfi_po_payment_request)).to be_valid }
    it { expect(create(:bill_nfi_po_payment_request)).to be_valid}
  end

  let(:advance_po_payment_request) { create(:advance_po_payment_request) }
  let(:bill_po_payment_request) { create(:bill_po_payment_request) }
  let(:partial_bill_po_payment_request) { create(:partial_bill_po_payment_request) }
  let(:advance_trip_payment_request) { create(:advance_trip_payment_request) }
  let(:bill_trip_payment_request) { create(:bill_trip_payment_request) }
  let(:advance_nfi_trip_payment_request) { create(:advance_nfi_trip_payment_request) }
  let(:bill_nfi_trip_payment_request) { create(:bill_nfi_trip_payment_request) }
  let(:advance_dc_payment_request) { create(:advance_dc_payment_request) }
  let(:bill_dc_payment_request) { create(:bill_dc_payment_request) }
  let(:per_unit_bill_dc_pr) { create(:per_unit_bill_dc_payment_request) }

  let(:dc_executive_user) { create(:dc_executive_user) }
  let(:buyer_user) { create(:buyer_user) }
  let(:buyer_approver_user) { create(:buyer_approver_user) }
  let(:finance_approver_user) { create(:finance_approver_user) }
  let(:logistic_approver_user) { create(:logistic_approver_user) }
  let(:finance_executive_user) { create(:finance_executive_user) }
  let(:treasury_user) { create(:treasury_user) }
  let(:approved_advance_po_payment_request) {  
                pr = create(:advance_po_payment_request) 
                pr.approved_date = Time.now
                pr.status = PaymentRequest::Status::APPROVED
                pr.approver = buyer_approver_user
                pr.save!
                return pr}
  let(:rejected_advance_po_payment_request) {  
                pr = create(:advance_po_payment_request) 
                pr.rejected_date = Time.now
                pr.status = PaymentRequest::Status::REJECTED
                pr.rejector = buyer_approver_user
                pr.save!
                return pr}
  let(:paid_advance_po_payment_request) {
                pr = approved_advance_po_payment_request
                pr.paid_date = Time.now
                pr.finance_approver = finance_approver_user
                pr.finance_approved_date = Time.now
                pr.status = PaymentRequest::Status::PAID
                pr.payer = treasury_user
                pr.vendor.kyc_docs.each do |kyc_doc|
                  kyc_doc.status = KycDoc::Status::VERIFIED
                  kyc_doc.save!
                end
                pr.vendor.bank_detail.status = BankDetail::Status::VERIFIED
                pr.vendor.bank_detail.save!
                pr.save!
                return pr}

  describe "ActiveModel validations" do
    # Basic validations
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:adjusted_amount).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_presence_of(:payment_request_type) }
    it { should validate_presence_of(:priority) }
    it { should belong_to(:cost_head) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:payment_request_type).in_array(PaymentRequest::PaymentRequestType.all) }
    it { should validate_inclusion_of(:priority).in_array(PaymentRequest::Priority.all) }
    it { expect(advance_po_payment_request).to validate_inclusion_of(:status).in_array(PaymentRequest::Status.all) }
    it "valid_amount_calculation" do
      pr = per_unit_bill_dc_pr
      expect(pr).to be_valid
      pr.units = nil
      expect {pr.save}.to raise_error()
      pr.units = 0
      expect(pr).not_to be_valid
      pr.units = -1
      expect(pr).not_to be_valid
      pr.units = 1
      expect(pr).not_to be_valid
      pr.units = 100
      expect(pr).to be_valid
      pr = advance_po_payment_request
      expect(pr).to be_valid
      pr.units = nil
      expect(pr).to be_valid
    end
    it "valid_category" do
      po_ch = create :fruit_ch
      non_ch = CostHead.create!(name: "Test", enabled_for_dc: false, enabled_for_trip: false, enabled_for_po: false)

      po_pr = bill_po_payment_request

      po_ch.enabled_for_po = false
      expect(po_ch).to_not be_valid

      expect(po_pr).to be_valid
      po_pr.cost_head_id = non_ch.id
      expect(po_pr).to_not be_valid

      trip_pr = bill_trip_payment_request
      expect(trip_pr).to be_valid
      trip_pr.cost_head_id = non_ch.id
      expect(trip_pr).to_not be_valid

      dc_pr = bill_dc_payment_request
      expect(dc_pr).to be_valid
      dc_pr.cost_head_id = non_ch.id
      expect(dc_pr).to_not be_valid
    end

    it "Validates if delivery of direct PO is completed" do
      po = create :direct_purchase_order
      creator = create :field_executive_user
      vendor = create :farmer
      approver = create :buyer_approver_user

      expect(build :advance_po_payment_request, purchase_order: po, creator: creator, vendor: vendor, approver_ids: [approver.id]).to_not be_valid

      po.shipments[0].delivery.update!(vehicle_arrival_time: Time.now, status: Delivery::Status::COMPLETED)
      po.reload

      apo = build :advance_po_payment_request, purchase_order: po, creator: creator, vendor: vendor, approver_ids: [approver.id]
      expect(apo).to be_valid
    end

    it 'validates_parent_bill' do
      po_bill_pr = partial_bill_po_payment_request
      adv_pr = advance_po_payment_request
      adv_pr.parent_bill = po_bill_pr
      expect(adv_pr).to be_valid
      adv_pr.parent_bill = adv_pr
      expect(adv_pr).to_not be_valid
      po_bill_pr.parent_bill = po_bill_pr
      expect(adv_pr).to_not be_valid
      po_bill_pr.parent_bill = adv_pr
      expect(adv_pr).to_not be_valid
    end

    it 'check for nfi_po_payment_request' do
      nfi_po_bill_pr = create(:bill_nfi_po_payment_request)
      expect(nfi_po_bill_pr).to be_valid

      shipments_value = nfi_po_bill_pr.nfi_shipments.map(&:total_accounted_value).sum.round(2)
      expect(nfi_po_bill_pr.update!(amount: shipments_value + 0.5)).to be_truthy
      expect do
        nfi_po_bill_pr.update!(amount: shipments_value + 1.1)
      end.to raise_error(ActiveRecord::RecordInvalid, /The payment request amount is greater than shipment value/)
    end
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:purchase_order).optional }
    it { should belong_to(:trip).optional }
    it { should belong_to(:nfi_trip).optional }
    it { should belong_to(:creator) }
    it { should belong_to(:approver).optional }
    it { should belong_to(:rejector).optional }
    it { should belong_to(:payer).optional }
    it { should belong_to(:farmer_token).optional }

    it { should have_many(:payment_request_shipments) }
    it { should have_many(:shipments) }
    it { should have_many(:payment_request_approvers) }
    it { should have_many(:approvers) }
    it { should have_many(:advance_amount_debited) }
    it { should have_many(:advance_amount_credited) }
    it { should have_many(:products).through(:purchase_order) }
    it { should_not have_many(:products).through(:farmer_token) }
    it { should have_many(:products_through_farmer_token).class_name('Product').through(:farmer_token).source(:products) }
    it { should_not have_many(:products_through_farmer_token).through(:purchase_order) }
  end

  context 'scope test' do
    it "of_parent_bill" do
      adv_pr = advance_po_payment_request
      adv_pr.parent_bill_id = partial_bill_po_payment_request.id
      adv_pr.save 
      expect(PaymentRequest.of_parent_bill(adv_pr.parent_bill_id).first.id).to eq(adv_pr.id)
    end
  end

  context "model methods test" do
    it "identifier" do
      expect(advance_po_payment_request.identifier).to eq("PR-#{advance_po_payment_request.id}")
    end

    it "of_purchase_order?" do
      expect(advance_po_payment_request.of_purchase_order?).to eq(true)
      expect(bill_po_payment_request.of_purchase_order?).to eq(true)
      expect(advance_trip_payment_request.of_purchase_order?).to eq(false)
      expect(bill_trip_payment_request.of_purchase_order?).to eq(false)
    end

    it "of_trip?" do
      expect(advance_po_payment_request.of_trip?).to eq(false)
      expect(bill_po_payment_request.of_trip?).to eq(false)
      expect(advance_trip_payment_request.of_trip?).to eq(true)
      expect(bill_trip_payment_request.of_trip?).to eq(true)
    end

    it "of_nfi_trip?" do
      expect(advance_nfi_trip_payment_request.of_nfi_trip?).to eq(true)
      expect(bill_nfi_trip_payment_request.of_nfi_trip?).to eq(true)
    end

    it "has_approver?" do
      expect(advance_po_payment_request.has_approver?).to eq(false)
      expect(bill_po_payment_request.has_approver?).to eq(false)
      expect(advance_trip_payment_request.has_approver?).to eq(false)
      expect(bill_trip_payment_request.has_approver?).to eq(false)
      expect(approved_advance_po_payment_request.has_approver?).to eq(true)
      expect(paid_advance_po_payment_request.has_approver?).to eq(true)
      expect(advance_nfi_trip_payment_request.has_approver?).to eq(false)
      expect(bill_nfi_trip_payment_request.has_approver?).to eq(false)
    end

    it "is_paid?" do
      expect(advance_po_payment_request.is_paid?).to eq(false)
      expect(bill_po_payment_request.is_paid?).to eq(false)
      expect(advance_trip_payment_request.is_paid?).to eq(false)
      expect(bill_trip_payment_request.is_paid?).to eq(false)
      expect(advance_nfi_trip_payment_request.is_paid?).to eq(false)
      expect(bill_nfi_trip_payment_request.is_paid?).to eq(false)
      expect(approved_advance_po_payment_request.is_paid?).to eq(false)
      expect(paid_advance_po_payment_request.is_paid?).to eq(true)
    end

    it "has_payer?" do
      expect(advance_po_payment_request.has_payer?).to eq(false)
      expect(bill_po_payment_request.has_payer?).to eq(false)
      expect(advance_trip_payment_request.has_payer?).to eq(false)
      expect(bill_trip_payment_request.has_payer?).to eq(false)
      expect(advance_nfi_trip_payment_request.has_payer?).to eq(false)
      expect(bill_nfi_trip_payment_request.has_payer?).to eq(false)
      expect(approved_advance_po_payment_request.has_payer?).to eq(false)
      expect(paid_advance_po_payment_request.has_payer?).to eq(true)
    end

    it "was_paid?" do
      expect(advance_po_payment_request.was_paid?).to eq(false)
      expect(bill_po_payment_request.was_paid?).to eq(false)
      expect(advance_trip_payment_request.was_paid?).to eq(false)
      expect(bill_trip_payment_request.was_paid?).to eq(false)
      expect(advance_nfi_trip_payment_request.was_paid?).to eq(false)
      expect(bill_nfi_trip_payment_request.was_paid?).to eq(false)
      expect(approved_advance_po_payment_request.was_paid?).to eq(false)
      expect(paid_advance_po_payment_request.was_paid?).to eq(true)
    end

    it "is_pending?" do
      expect(advance_po_payment_request.is_pending?).to eq(true)
      expect(bill_po_payment_request.is_pending?).to eq(true)
      expect(advance_trip_payment_request.is_pending?).to eq(true)
      expect(bill_trip_payment_request.is_pending?).to eq(true)
      expect(advance_nfi_trip_payment_request.is_pending?).to eq(true)
      expect(bill_nfi_trip_payment_request.is_pending?).to eq(true)
      expect(approved_advance_po_payment_request.is_pending?).to eq(false)
      expect(paid_advance_po_payment_request.is_pending?).to eq(false)
    end

    it "is_rejected?" do
      expect(advance_po_payment_request.is_rejected?).to eq(false)
      expect(bill_po_payment_request.is_rejected?).to eq(false)
      expect(advance_trip_payment_request.is_rejected?).to eq(false)
      expect(bill_trip_payment_request.is_rejected?).to eq(false)
      expect(advance_nfi_trip_payment_request.is_rejected?).to eq(false)
      expect(bill_nfi_trip_payment_request.is_rejected?).to eq(false)
      expect(approved_advance_po_payment_request.is_rejected?).to eq(false)
      expect(paid_advance_po_payment_request.is_rejected?).to eq(false)
      expect(rejected_advance_po_payment_request.is_rejected?).to eq(true)
    end

    it "is_advance_payment_request?" do
      expect(advance_po_payment_request.is_advance_payment_request?).to eq(true)
      expect(bill_po_payment_request.is_advance_payment_request?).to eq(false)
      expect(advance_trip_payment_request.is_advance_payment_request?).to eq(true)
      expect(bill_trip_payment_request.is_advance_payment_request?).to eq(false)
      expect(advance_nfi_trip_payment_request.is_advance_payment_request?).to eq(true)
      expect(bill_nfi_trip_payment_request.is_advance_payment_request?).to eq(false)
      expect(approved_advance_po_payment_request.is_advance_payment_request?).to eq(true)
      expect(paid_advance_po_payment_request.is_advance_payment_request?).to eq(true)
      expect(rejected_advance_po_payment_request.is_advance_payment_request?).to eq(true)
    end

    it "is_bill_payment_request?" do
      expect(advance_po_payment_request.is_bill_payment_request?).to eq(false)
      expect(bill_po_payment_request.is_bill_payment_request?).to eq(true)
      expect(advance_trip_payment_request.is_bill_payment_request?).to eq(false)
      expect(bill_trip_payment_request.is_bill_payment_request?).to eq(true)
      expect(advance_nfi_trip_payment_request.is_bill_payment_request?).to eq(false)
      expect(bill_nfi_trip_payment_request.is_bill_payment_request?).to eq(true)    
      expect(approved_advance_po_payment_request.is_bill_payment_request?).to eq(false)
      expect(paid_advance_po_payment_request.is_bill_payment_request?).to eq(false)
      expect(rejected_advance_po_payment_request.is_bill_payment_request?).to eq(false)
    end

    it "created_date_epoch" do
      expect(advance_po_payment_request.created_date_epoch).to eq(advance_po_payment_request.created_date.utc.to_epoch)
    end

    it "due_date_epoch" do
      expect(advance_po_payment_request.due_date_epoch).to eq(advance_po_payment_request.due_date.utc.to_epoch)
    end

    it "approved_date_epoch" do    
      expect(approved_advance_po_payment_request.approved_date_epoch).to eq(approved_advance_po_payment_request.approved_date.utc.to_epoch)
    end

    it "paid_date_epoch" do
      expect(paid_advance_po_payment_request.paid_date_epoch).to eq(paid_advance_po_payment_request.paid_date.utc.to_epoch)
    end

    it "rejected_date_epoch" do
      expect(rejected_advance_po_payment_request.rejected_date_epoch).to eq(rejected_advance_po_payment_request.rejected_date.utc.to_epoch)
    end

    it "creator_name" do
      expect(paid_advance_po_payment_request.creator_name).to eq(paid_advance_po_payment_request.creator.name)
    end

    it "approver_name" do
      expect(paid_advance_po_payment_request.approver_name).to eq(paid_advance_po_payment_request.approver.name)
    end

    it "payer_name" do
      expect(paid_advance_po_payment_request.payer_name).to eq(paid_advance_po_payment_request.payer.name)
    end

    it "rejector_name" do
      expect(rejected_advance_po_payment_request.rejector_name).to eq(rejected_advance_po_payment_request.rejector.name)
    end

    # it "vendor" do
    #   expect(advance_po_payment_request.vendor).to eq(advance_po_payment_request.purchase_order.partner)
    #   expect(advance_trip_payment_request.vendor).to eq(advance_trip_payment_request.trip.trip_meta_infos.first.partner)
    # end

    it "is_vendor_kyc_verified?" do
      expect(advance_po_payment_request.is_vendor_kyc_verified?).to eq(false)
      expect(paid_advance_po_payment_request.is_vendor_kyc_verified?).to eq(true)
    end

    it "is_vendor_bank_verified?" do
      expect(advance_po_payment_request.is_vendor_bank_verified?).to eq(false)
      expect(paid_advance_po_payment_request.is_vendor_bank_verified?).to eq(true)
    end

    it "is_vendor_kyc_bank_pending?" do
      expect(advance_po_payment_request.is_vendor_kyc_bank_pending?).to eq(false)
    end

    it "is_vendor_kyc_bank_verified?" do
      expect(advance_po_payment_request.is_vendor_kyc_bank_verified?).to eq(false)
      expect(paid_advance_po_payment_request.is_vendor_kyc_bank_verified?).to eq(true)
    end

    it "agreement" do
      expect(advance_po_payment_request.agreement).to eq(advance_po_payment_request.purchase_order.agreement)
    end

    it "payment_request_type_label" do
      expect(advance_po_payment_request.payment_request_type_label).to eq("Advance")
      expect(bill_po_payment_request.payment_request_type_label).to eq("Bill")
    end

    it "source_label" do
      expect(advance_po_payment_request.source_label).to eq(advance_po_payment_request.purchase_order.identifier)
      expect(bill_po_payment_request.source_label).to eq(bill_po_payment_request.purchase_order.identifier)
      expect(advance_trip_payment_request.source_label).to eq(advance_trip_payment_request.trip.identifier)
      expect(bill_trip_payment_request.source_label).to eq(bill_trip_payment_request.trip.identifier)
      expect(advance_nfi_trip_payment_request.source_label).to eq(advance_nfi_trip_payment_request.nfi_trip.identifier)
      expect(bill_nfi_trip_payment_request.source_label).to eq(bill_nfi_trip_payment_request.nfi_trip.identifier)
    end

    it "status_label" do
      expect(advance_po_payment_request.status_label).to eq("Pending")
      expect(approved_advance_po_payment_request.status_label).to eq("Business Approved")
      expect(rejected_advance_po_payment_request.status_label).to eq("Rejected")
      expect(paid_advance_po_payment_request.status_label).to eq("Paid")
    end

    it "priority_label" do
      expect(advance_po_payment_request.priority_label).to eq("Low")
    end

    it "filters" do
      expect(PaymentRequest.of_vendor(bill_trip_payment_request.vendor_id)).to eq([bill_trip_payment_request])
      expect(PaymentRequest.after(bill_trip_payment_request.created_date)).to include(bill_trip_payment_request)
      expect(PaymentRequest.before(bill_trip_payment_request.created_date)).to include(bill_trip_payment_request)
      expect(PaymentRequest.of_id(bill_trip_payment_request.id)).to eq([bill_trip_payment_request])
    end

    it "is_fruit_category?" do
      expect(advance_po_payment_request.cost_head.is_primary_fruit_head?).to eq(true)
      expect(bill_po_payment_request.cost_head.is_primary_fruit_head?).to eq(true)
      expect(bill_dc_payment_request.cost_head.is_primary_fruit_head?).to eq(false)
      expect(advance_trip_payment_request.cost_head.is_primary_fruit_head?).to eq(false)
    end

    it "updates paid data for all prs in the batch" do
      # TODO Arun - complete test
    end

    it "approve paid by customer update_with_batch" do
      bill_po_payment_request_customer_paid =  create(:bill_po_payment_request_customer_paid)
      params = {status: 2, approver_id: buyer_approver_user.id, approved_date: Time.now}
      bill_po_payment_request_customer_paid.update_with_batch!(params)
      expect(bill_po_payment_request_customer_paid.status).to eq(2)
      params = {status: "8", finance_approver_id: finance_approver_user.id, finance_approved_date: Time.now}
      bill_po_payment_request_customer_paid.update_with_batch!(params)
      expect(bill_po_payment_request_customer_paid.status).to eq(4)
    end

    it 'has_balance_bill_payment_request?' do
      po_bill_pr = partial_bill_po_payment_request
      expect(po_bill_pr.has_balance_bill_payment_request?).to eq(false)
      adv_pr = create :advance_po_payment_request, amount:1000, parent_bill: po_bill_pr
      expect(po_bill_pr.has_balance_bill_payment_request?).to eq(true)
    end

    it 'balance_pr_amount_raised' do
      po_bill_pr = partial_bill_po_payment_request
      expect(po_bill_pr.balance_pr_amount_raised).to eq(0)
      adv_pr = create :advance_po_payment_request, amount:1000, parent_bill: po_bill_pr
      expect(po_bill_pr.balance_pr_amount_raised).to eq(1000)
      adv_pr = create :advance_po_payment_request, amount:100, parent_bill: po_bill_pr
      expect(po_bill_pr.balance_pr_amount_raised).to eq(1100)
    end

    it 'update_is_partial_bill' do
      po_bill_pr = partial_bill_po_payment_request
      expect(po_bill_pr.is_partial_bill).to eq(true)
      adv_pr = create :advance_po_payment_request, amount:1000, parent_bill: po_bill_pr
      expect(po_bill_pr.is_partial_bill).to eq(true)
      adv_pr = create :advance_po_payment_request, amount:650, parent_bill: po_bill_pr
      expect(po_bill_pr.is_partial_bill).to eq(false)
    end
  end

  describe '.get_vendor_remaining_amount' do

    let!(:purchase_order) { create(:farmer_purchase_order_with_loaded_shipment) } 

    let!(:payment_request) { create(:advance_po_payment_request, purchase_order: purchase_order, amount: 500) }

    it 'returns the correct remaining amount for a vendor' do

      vendor = purchase_order.partner
      payment_request.update_columns(status: PaymentRequest::Status::PAID)
      expected_remaining_amount_vendor = payment_request.amount
      expect(PaymentRequest.get_vendor_remaining_amount(vendor.id)).to eq(expected_remaining_amount_vendor)
    end
  end

end
