FactoryBot.define do
  factory :inventory_adjustment do
    description {"Test Inventory Adjustment"}
    weight {50}
    date {Time.now}
    dc factory: :hyd_dc
    product factory: :pomo
    chamber factory: :chamber
    
    factory :customer_gap_inv_adj do
      reason {InventoryAdjustment::Reason::CustomerGap}
      source_type {InventoryAdjustment::SourceType::SaleOrderItem}
      sale_order_item factory: :soi_pomo
    end

    factory :dump_inv_adj do
      reason {InventoryAdjustment::Reason::Dump}
      source_type {InventoryAdjustment::SourceType::Lot}
      lot factory: :dc_lot_with_grade_c
    end

    factory :moisture_loss_inv_adj do
      reason {InventoryAdjustment::Reason::MoistureLoss}
      source_type {InventoryAdjustment::SourceType::Regrade}
      # TODO: add regrade tracker, regradings factory
    end

    factory :transit_gap_inv_adj do
      reason {InventoryAdjustment::Reason::TransitGap}
      source_type {InventoryAdjustment::SourceType::DcDeliveryLot}
      lot factory: :dc_lot_with_parent_lot_and_partial
    end

    factory :transit_moisture_loss_inv_adj do
      reason {InventoryAdjustment::Reason::TransitMoistureLoss}
      source_type {InventoryAdjustment::SourceType::DcDeliveryLot}
      lot factory: :dc_lot_with_parent_lot_and_partial
    end

  end
end
