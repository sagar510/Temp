FactoryBot.define do
  factory :lot do
    quantity {10}
    average_weight {9.5}
    nfi_packaging_item
    sku {build(:sku_pomo)}
    description {"Test Lot"}
    lot_type {Lot::LotType::NONSTANDARD}
    
    factory :dc_lot do
      identifier {'DC-LOT/POMO/200-300'}
      current_weight {50}
      created_date {1.day.ago}
      dc factory: :hyd_dc
      chamber factory: :chamber
      
      factory :standard_dc_lot do
        chamber { create :chamber }
        lot_type {Lot::LotType::STANDARD}
      end
      
      factory :dc_lot_with_partial do
        partial_weight {5}
        has_partial {true}

        factory :standard_dc_lot_with_partial do
          lot_type {Lot::LotType::STANDARD}
        end
      end

      factory :dc_lot_with_parent_lot do
        quantity {8}
        average_weight {9}
        parent_lot {create(:harvest_lot_with_partial)}

        factory :standard_dc_lot_with_parent_lot do
          lot_type {Lot::LotType::STANDARD}
        end
      end

      factory :direct_po_dc_lot_with_parent_lot do
        parent_lot {create(:direct_po_lot)}
      end

      factory :dc_lot_with_parent_lot_and_partial do
        quantity {8}
        average_weight {9}
        partial_weight {5}
        has_partial {true}
        parent_lot {create(:harvest_lot_with_partial)}

        factory :standard_dc_lot_with_parent_lot_and_partial do
          lot_type {Lot::LotType::STANDARD}
        end
      end

      factory :dc_lot_with_grade_c do
        partial_weight {5}
        has_partial {true}
        sku {build(:sku_pomo_grade_c)}

        factory :standard_dc_lot_with_grade_c do
          lot_type {Lot::LotType::STANDARD}
        end
      end
    end

    factory :harvest_lot do
      lot_item factory: :si_pomo
      shipment {create :farm_to_dc_shipment }
      created_date {1.day.ago}

      factory :harvest_lot_with_partial do
        lot_item factory: :si_pomo_sb
        partial_weight {5}
        has_partial {true}
      end

      after(:create) do |harvest_lot|
        create :harvest_shipment, shipment: harvest_lot.shipment, harvest: harvest_lot.shipment.sender.harvests.first
      end
    end

    factory :child_lot_to_do_partial_unloading do
      quantity {0}
      current_weight {0}
      lot_item factory: :si_pomo
      parent_lot factory: :harvest_lot_hyd_dc
    end

    factory :harvest_lot_hyd_dc do
      lot_item factory: :si_pomo
      shipment {create :farm_to_dc_shipment_hyd_dc }
      created_date {1.day.ago}
    end

    factory :direct_po_lot do
      lot_item factory: :si_pomo
      shipment {create :direct_po_to_dc_shipment }
      created_date {1.day.ago}
    end

    factory :dc_to_dc_shipment_lot do
      shipment factory: :dc_to_dc_shipment
      initial_weight {95}

      factory :standard_dc_to_dc_shipment_lot do
        lot_type {Lot::LotType::STANDARD}
      end
    end

    factory :cso_to_dc_shipment_lot do
      shipment factory: :cso_to_dc_shipment

      factory :standard_cso_to_dc_shipment_lot do
        lot_type {Lot::LotType::STANDARD}
      end
    end

    factory :sale_order_lot do
      lot_item factory: :si_pomo
      shipment {create :dc_to_so_shipment }
      created_date {1.day.ago}
    end

    factory :moi_lot do
      material_order_item factory: :moi_for_amo
    end

  end
end