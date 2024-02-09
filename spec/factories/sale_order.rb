FactoryBot.define do
  factory :sale_order do
    dc {create(:hyd_dc)}
    status { SaleOrder::Status::YET_TO_ALLOT }
    customer {create(:customer_mt)}
    customer_location {create(:customer_location)}
    user {create(:sales_executive_user)}
    expected_delivery_time {Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)}

    factory (:direct_sale) do
      sale_type { SaleOrder::SaleType::DIRECT }
    end

    factory (:indirect_sale) do
      sale_type { SaleOrder::SaleType::INDIRECT }
    end

    comments {"direct or indirect sale"}

    factory (:central_sale_order) do
      dc factory: :dc_cdc
      sale_type { SaleOrder::SaleType::INDIRECT }
    end

    factory (:so_one) do
      sale_type {SaleOrder::SaleType::INDIRECT}
      liquidation {false}
      patti {false}
      void {false}
      zoho_published {false}
    end
  end

  factory :so_invalid_1, class: SaleOrder do
    sale_type {SaleOrder::SaleType::INDIRECT}
    liquidation {false}
    patti {false}
    void {false}
    zoho_published {false}
  end

  factory :so_for_amo, class: SaleOrder do
    sale_type {SaleOrder::SaleType::INDIRECT}
    dc factory: :hyd_dc
    customer factory: :customer_mt
    customer_location factory: :customer_location
    user factory: :sales_executive_user
    expected_delivery_time {Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)}

    factory :so_with_soi_and_moi_for_amo do
      after(:create) do |sale_order|
        create :soi_with_moi_for_amo, sale_order: sale_order
      end
    end
  end
end
