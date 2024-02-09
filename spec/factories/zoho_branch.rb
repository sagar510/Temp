FactoryBot.define do
    factory :zoho_branch, class: ZohoBranch do
        zoho_branch_name { Faker::Lorem.sentence(word_count: 1) }
        zoho_branch_id { Faker::Number.unique.number(digits: 12) }
        is_branch_active { true }
        is_primary_branch { true }
        tax_reg_no { Faker::Number.unique.number(digits: 12) }
        tax_settings_id { Faker::Number.unique.number(digits: 12) }
    end
end