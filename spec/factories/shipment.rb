FactoryBot.define do
  factory :shipment do
    instructions {Faker::Lorem.sentence(word_count: 5)}

    factory :po_to_dc_shipment do
      recipient factory: :material_order

      factory :farm_to_dc_shipment do
        sender factory: :farmer_purchase_order
        delivery factory: :delivery
        pickup factory: :pickup

        factory :farm_to_dc_loaded_shipment do
          after(:create) do |shipment|
            shipment.lots.each do |lot|
              initial_weight = lot.average_weight * 10 + 5
              lot.update_columns(quantity: 10, partial_weight: 5, has_partial: true, current_weight: initial_weight, initial_weight: initial_weight)
            end
          end
        end
      end
      
      factory :farm_to_dc_shipment_hyd_dc do
        sender factory: :farmer_purchase_order
        delivery factory: :delivery_hyd_dc
        pickup factory: :pickup
      end

      factory :direct_po_to_dc_shipment do
        sender factory: :direct_purchase_order
      end

      after(:create) do |shipment|
        packaging_item = create(:nfi_packaging_item)
        create :si_pomo, shipment: shipment, purchase_order: shipment.sender, weight_in_kgs: 60, average_weight: 20, nfi_packaging_item: packaging_item, parent_id: shipment.sender.purchase_items.first.id
        create :si_pomo_sb, shipment: shipment, purchase_order: shipment.sender, weight_in_kgs: 50, average_weight: 10, nfi_packaging_item: packaging_item, parent_id: shipment.sender.purchase_items.first.id
      end
    end

    factory :farm_to_cso_shipment do
      sender {create :farmer_purchase_order}
      sender_type = Shipment::SenderType::PURCHASEORDER
      recipient {create :material_order_for_central_sale_order}
      after(:create) do |shipment| 
        mo = shipment.recipient
        sale_order = shipment.recipient.sale_order

        mo.sender_purchase_order = shipment.sender
        mo.parent_material_order = sale_order.material_order 
        mo.save!
      end
    end

    factory :dc_to_dc_shipment do
      sender {create :dc}
      recipient {(create :mo_with_child_mo_for_amo).child_mos.first}
    end

    factory :transfer_order_shipment do
      pickup factory: :pickup
      sender {create :b2r_bangalore_dc}
      recipient factory: :material_order
    end

    factory :dc_to_so_shipment do
      sender {create :dc}
      recipient {create :indirect_sale}
    end

    factory :cso_to_dc_shipment do
      sender factory: :central_sale_order
      recipient factory: :material_order
    end

    factory :cso_to_cso_shipment do
      sender factory: :central_sale_order
      recipient factory: :material_order_for_central_sale_order
    end

  end
end