FactoryBot.define do
    
    factory :product_issue_pomo, class: ProductIssue do 
        product {build(:pomo)}
        issue {Faker::Name.first_name}
    end

end