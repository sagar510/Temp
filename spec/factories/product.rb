FactoryBot.define do
    factory :product, class: Product do 
        name { nil }
        code { nil }
    end

    factory :pomo, class: Product do 
        name {"Pomegranate"}
        code {"POMO"}
        product_category factory: :pomo_product_category
        initialize_with { Product.find_or_create_by(code: code)}
    end

    factory :orange, class: Product do
        name {"Orange"}
        code {"ORAN"}
        product_category factory: :orange_product_category

        initialize_with { Product.find_or_create_by(code: code)}
    end

    factory :grapes, class: Product do 
        name {"Grapes"}
        code {"GRAP"}
        product_category factory: :grapes_product_category

        initialize_with { Product.find_or_create_by(code: code)}
    end
    
    factory :kinnow, class: Product do  
        name {"Kinnow"}
        code {"KINN"}
        initialize_with { Product.find_or_create_by(code: code)}
        product_category factory: :kinnow_product_category
    end

end