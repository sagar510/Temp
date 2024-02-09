FactoryBot.define do

  sequence(:unique_product_category_short_code) do |n|
    code = nil
    loop do
      code = Faker::Lorem.characters(number: 3, min_alpha: 3).upcase
      break unless ProductCategory.exists?(short_code: code)
    end
    code
  end
    
  factory :pomo_product_category, class: ProductCategory do 
      name {"Pomegranate"}
      notif_channel {'pomegrante'}
      accounts_channel {'pomo'}
      short_code { generate(:unique_product_category_short_code) }
  end

  factory :orange_product_category, class: ProductCategory do 
    name {"Orange"}
    notif_channel {'orange'}
    accounts_channel {'orange'}
    short_code { generate(:unique_product_category_short_code) }
  end


  factory :grapes_product_category, class: ProductCategory do 
    name {"Grapes"}
    notif_channel {'grapes'}
    accounts_channel {'grapes'}
    short_code { generate(:unique_product_category_short_code) }
  end


  factory :kinnow_product_category, class: ProductCategory do 
    name {"kinnow"}
    notif_channel {'kinnow'}
    accounts_channel {'kinnow'}
    short_code { generate(:unique_product_category_short_code) }
  end

end