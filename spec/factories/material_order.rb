FactoryBot.define do
  factory :material_order do
    dc factory: :hyd_dc

    factory (:material_order_for_central_sale_order) do
      sale_order { create(:central_sale_order) }
      # shipment { create(:cso_to_dc_shipment)}
    end

    expected_delivery_time {Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)}
    loading_time {Faker::Time.between(from: DateTime.now - 10, to: DateTime.now + 10)}
  end

  factory :mo_for_amo, class: MaterialOrder do
    dc factory: :hyd_dc
    order_created_time {Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)}
    expected_delivery_time {Faker::Time.between(from: DateTime.now, to: DateTime.now + 10)}
    created_by { 'System' }
    status {MaterialOrder::Status::PENDING_APPROVAL}

    factory :unapproved_amo do
      status {MaterialOrder::Status::PENDING_APPROVAL}
    end

    factory :approved_amo do
      status {MaterialOrder::Status::APPROVED}
    end

    factory :child_mo_for_amo do
      sender_dc factory: :dc
      parent_material_order factory: :mo_for_amo
    end

    factory :mo_with_child_mo_for_amo do
      status {MaterialOrder::Status::ASSIGNED_TO_SUPPLY}
      after(:create) do |material_order|
        material_order.material_order_items = create_list(:moi_for_amo, 1, material_order: material_order)
        child_mo = create :child_mo_for_amo, parent_material_order: material_order
        child_mo.material_order_items = create_list(:moi_for_amo, 1, material_order: child_mo, parent_material_order_item_id: material_order.material_order_items[0].id )
      end
    end

    factory :mo_with_allotted_child_mo_for_amo do
      status {MaterialOrder::Status::ALLOTTED}
      after(:create) do |material_order|
        material_order.material_order_items = create_list(:moi_for_amo, 1, material_order: material_order)
        child_mo = create :child_mo_for_amo, parent_material_order: material_order
        child_mo.material_order_items = create_list(:moi_for_amo, 1, material_order: child_mo, parent_material_order_item_id: material_order.material_order_items[0].id )
      end
    end

    factory :mo_with_moi_and_soi_for_amo do
      after(:create) do |material_order|
        create :moi_with_soi_for_amo, material_order: material_order
      end
    end
  end
end