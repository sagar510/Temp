FactoryBot.define do
  factory :purchase_order do
    address { "No.13, Ground floor, MCHS Sector-4, HSR layout, Bengaluru 560102" }
    expected_harvest_date {1.day.ago}
    service_provider
    location factory: :farm_location 
    
    factory (:farmer_purchase_order) do
      purchase_order_type {1}
      partner factory: :farmer
      micro_pocket factory: :micro_pocket
      model {PurchaseOrder::Model::COMMISION}
      factory (:farmer_purchase_order_with_shipment) do
        after(:create) do |purchase_order|
          create :farm_to_dc_shipment, sender: purchase_order
        end
      end
      factory (:farmer_purchase_order_with_loaded_shipment) do
        partner factory: :farmer_with_kyc_and_bank_detail
        after(:create) do |purchase_order|
          create :farm_to_dc_loaded_shipment, sender: purchase_order
        end
      end
    end

    factory (:supplier_purchase_order) do
      purchase_order_type {PurchaseOrder::PurchaseOrderType::FarmGate}
      micro_pocket factory: :micro_pocket
      partner factory: :supplier
    end

    factory (:vendor_purchase_order) do
      micro_pocket factory: :micro_pocket
      partner factory: :supplier
      purchase_order_type {PurchaseOrder::PurchaseOrderType::Vendor}
    end

    factory (:direct_purchase_order) do
      micro_pocket factory: :micro_pocket
      partner factory: :supplier
      purchase_order_type {PurchaseOrder::PurchaseOrderType::Direct}
      after(:create) do |purchase_order|
        create :direct_po_to_dc_shipment, sender: purchase_order
      end
    end

    after(:create) do |purchase_order|
      create :buyer_purchase_oder_user, purchase_order: purchase_order
      create :field_executive_purchase_oder_user, purchase_order: purchase_order
      create :pi_pomo, purchase_order: purchase_order
    end
  end
end


