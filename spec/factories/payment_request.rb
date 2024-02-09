FactoryBot.define do
  factory :payment_request do
    created_date {1.day.ago}
    due_date {1.day.from_now}
    priority {PaymentRequest::Priority::LOW}
    status {PaymentRequest::Status::PENDING}
    creator factory: :field_executive_user

    factory :po_payment_request do
      purchase_order factory: :farmer_purchase_order_with_loaded_shipment
      cost_head factory: :fruit_ch

      before(:create) do |pr|
        buyer_approver_user1 = create(:buyer_approver_user)
        buyer_approver_user2 = create(:buyer_approver_user)
        pr.approver_ids = [buyer_approver_user1.id, buyer_approver_user2.id]
        pr.vendor = pr.purchase_order.partner
      end

      factory :advance_po_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::ADVANCE}
        amount {1000}
      end
      factory :bill_po_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        amount {4650.0}
        before(:create) do |pr|
          pr.shipment_ids = pr.purchase_order.shipments.map(&:id)
        end
      end
      factory :partial_bill_po_payment_request do
        is_partial_bill {true}
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        amount {3000.0}
        before(:create) do |pr|
          pr.shipment_ids = pr.purchase_order.shipments.map(&:id)
        end
      end
      factory :bill_po_payment_request_customer_paid do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        amount {4650.0}
        customer factory: :customer
        before(:create) do |pr|
          pr.shipment_ids = pr.purchase_order.shipments.map(&:id)
        end
      end
    end

    factory :trip_payment_request do
      cost_head factory: :transport_ch
      trip factory: :trip_with_shipments

      before(:create) do |pr|
        logistic_approver_user1 = create(:logistic_approver_user)
        logistic_approver_user2 = create(:logistic_approver_user)
        pr.approver_ids = [logistic_approver_user1.id, logistic_approver_user2.id]
        pr.vendor = pr.trip.trip_meta_infos.first.partner
      end

      factory :advance_trip_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::ADVANCE}
        amount {1000}
      end
      factory :bill_trip_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        adjusted_amount {500}
        amount {9500}
        inam_amount  {250}
        demurrage_amount {550}
      end
    end

    factory :nfi_trip_payment_request do
      cost_head factory: :transport_ch
      nfi_trip factory: :nfi_trip_with_shipment

      before(:create) do |pr|
        logistic_approver_user1 = create(:logistic_approver_user)
        logistic_approver_user2 = create(:logistic_approver_user)
        pr.approver_ids = [logistic_approver_user1.id, logistic_approver_user2.id]
        pr.vendor = pr.nfi_trip.trip_meta_infos.first.partner
      end

      factory :advance_nfi_trip_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::ADVANCE}
        amount {100}
      end

      factory :bill_nfi_trip_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        adjusted_amount {500}
        amount {111500}
        inam_amount  {250}
        demurrage_amount {550}
      end
    end

    factory :nfi_po_payment_request do
      cost_head factory: :nfi_po_ch
      nfi_purchase_order factory: :normal_po_with_shipment

      before(:create) do |pr|
        user = create(:nfi_approver)
        pr.approver_ids = [user.id]
        pr.vendor = pr.nfi_purchase_order.partner
      end

      factory :advance_nfi_po_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::ADVANCE}
        amount {100}
      end

      factory :bill_nfi_po_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        amount {100}
        before(:create) do |pr|
          pr.nfi_shipment_ids = pr.nfi_purchase_order.shipments.map(&:id)
        end
      end
    end

    factory :dc_payment_request do
      dc factory: :hyd_dc
      cost_head factory: :rent_ch
      start_time {32.day.ago}
      end_time {2.day.ago}
      vendor factory: :other_with_kyc_and_bank_detail

      before(:create) do |pr|
        dc_approver_user1 = create(:dc_approver_user)
        dc_approver_user2 = create(:dc_approver_user)
        pr.approver_ids = [dc_approver_user1.id, dc_approver_user2.id]
      end

      factory :advance_dc_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::ADVANCE}
        amount {1000}
      end
      factory :bill_dc_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        adjusted_amount {500}
        amount {9500}
      end
      factory :per_unit_bill_dc_payment_request do
        payment_request_type {PaymentRequest::PaymentRequestType::BILL}
        adjusted_amount {500}
        amount {9500}
        per_unit_price {95}
        units {100}
      end
    end
  end
end
      