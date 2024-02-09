FactoryBot.define do
  factory :fruit_ch, class: CostHead do
    initialize_with { CostHead.where(name: "Fruit").first_or_initialize }
    enabled_for_dc {false}
    enabled_for_po {true}
    enabled_for_trip {false}
    require_agreeement {false}
    is_auto_computed {true}
  end

  factory :labour_ch, class: CostHead do
    initialize_with { CostHead.where(name: "Labour").first_or_initialize }
    enabled_for_dc {true}
    enabled_for_po {true}
    enabled_for_trip {false}
    require_agreeement {false}
    is_auto_computed {false}
  end

  factory :rent_ch, class: CostHead do
    initialize_with { CostHead.where(name: "Rent").first_or_initialize }
    enabled_for_dc {true}
    enabled_for_po {false}
    enabled_for_trip {false}
    require_agreeement {false}
    is_auto_computed {false}
  end

  factory :transport_ch, class: CostHead do
    initialize_with { CostHead.where(name: "Transportation").first_or_initialize }
    enabled_for_dc {true}
    enabled_for_po {true}
    enabled_for_trip {true}
    require_agreeement {false}
    is_auto_computed {false}
  end

  factory :grading_ch, class: CostHead do
    initialize_with { CostHead.where(name: "Grading Machine").first_or_initialize }
    enabled_for_dc {true}
    enabled_for_po {false}
    enabled_for_trip {false}
    require_agreeement {false}
    is_auto_computed {false}
  end

  factory :commision_ch, class: CostHead do
    initialize_with { CostHead.where(name: "Commission").first_or_initialize }
    enabled_for_dc {false}
    enabled_for_po {true}
    enabled_for_trip {false}
    require_agreeement {false}
    is_auto_computed {false}
  end

  factory :nfi_po_ch, class: CostHead do
    initialize_with { CostHead.where(name: "NonFruit").first_or_initialize }
    enabled_for_dc {false}
    enabled_for_nfi_po {true}
    enabled_for_po {false}
    enabled_for_trip {false}
    require_agreeement {false}
    is_auto_computed {false}
  end
end