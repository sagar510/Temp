FactoryBot.define do
  factory :sku do
    product factory: :pomo
    description {"POMO sku"}
    min_weight {100}
    max_weight {300}
    grade {"100-300"}
    hierarchy_rank {1}
    output_regrade_qualifier {true}

    factory :random_grade_pomo_sku do
      grade { Faker::Name.first_name }
    end
  end

  factory :random_pomo_sku do
    product factory: :pomo
    description {"POMO sku"}
    grade {Faker::Name.first_name}
  end

  factory :sku_pomo, class: Sku do
    product factory: :pomo
    description {"POMO sku"}
    min_weight {200}
    max_weight {300}
    grade {"200-300"}
    initialize_with { Sku.find_or_create_by(grade: grade, product: product)}
  end

  factory :sku_pomo_inactive, class: Sku do
    product factory: :pomo
    description {"POMO sku"}
    min_weight {200}
    max_weight {300}
    grade {"20-300"}
    active {false}
    initialize_with { Sku.find_or_create_by(grade: grade, product: product, active: active)}
  end

  factory :sku_kinnow_72, class: Sku do
    product factory: :kinnow
    description {"KINNOW 72 sku"}
    min_weight {Faker::Number.between(from: 50, to: 100)}
    max_weight {min_weight + Faker::Number.between(from: 20, to: 50)}
    grade { "72" }
  end

  factory :sku_pomo_sb, class: Sku do
    product factory: :pomo
    description {"POMO sb sku"}
    min_weight {Faker::Number.between(from: 50, to: 100)}
    max_weight {min_weight + Faker::Number.between(from: 20, to: 50)}
    grade {min_weight.to_s + "-" + max_weight.to_s}
    initialize_with { Sku.find_or_create_by(grade: grade, product: product)}
  end

  factory :sku_pomo_grade_c, class: Sku do
    product factory: :pomo
    description {"POMO Grade C"}
    grade {Sku::DefaultGrades::C}
    initialize_with { Sku.find_or_create_by(grade: grade, product: product)}
  end

  factory :non_output_sku do
    product factory: :pomo
    description {"POMO sku"}
    min_weight {100}
    max_weight {300}
    grade {"100-300"}
    hierarchy_rank {3}
    output_regrade_qualifier {false}
  end

end
