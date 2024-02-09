FactoryBot.define do
  factory :user, class: User do
    email {Faker::Internet.unique.email}
    password {"qwerty"}
    password_confirmation {"qwerty"}
    username {Faker::Name.unique.first_name}
    name {Faker::Name.unique.first_name}
    phone_number {Faker::PhoneNumber.unique.cell_phone}

    factory :field_executive_user do
      name {'field executive'} 
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::FIELD_EXEC)
      end
    end

    factory :admin_user do 
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::ADMIN)
      end
    end

    factory :farmer_engagement_executive_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::FARMER_ENG_EXEC)
      end
    end

    factory :buyer_user do 
      name {'buyer'}
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::BUYER)
      end
    end

    factory :dc_manager_user do 
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_MANAGER)
      end
    end

    factory :dc_executive_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_EXECUTIVE)
      end
    end

    factory :logistics_manager_user do 
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::LOGISTICS_MANAGER)
      end
    end

    factory :sales_executive_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::SALES_EXEC)
      end
    end

    factory :buyer_approver_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::BUYER_APP)
      end
    end

    factory :finance_approver_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::FINANCE_APPROVER)
      end
    end

    factory :logistic_approver_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::LOGISTIC_APP)
      end
    end

    factory :dc_approver_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_APP)
      end
    end

    factory :finance_executive_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::FINANCE_EXEC)
      end
    end

    factory :treasury_user do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::TREASURY)
      end
    end

    factory :market_intelligence_exec do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::MI)
      end
    end
    
    factory :logistics_executive do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::LOGISTICS_EXECUTIVE)
      end
    end

    factory :transportation_procurement_team do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::TRANSPORTATION_PROCUREMENT_TEAM)
      end
    end

    factory :zonal_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::ZONAL_HEAD)
      end
    end

    factory :transportation_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::TRANSPORTATION_HEAD)
      end
    end

    factory :product_regional_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::PRODUCT_REGIONAL_HEAD)
      end
    end

    factory :supply_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::SUPPLY_HEAD)
      end
    end

    factory :product_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::PRODUCT_HEAD)
      end
    end

    
    factory :demand_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DEMAND_HEAD)
      end
    end

    factory :mt_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::MT_HEAD)
      end
    end

    factory :city_manager do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::CITY_MANAGER)
      end
    end

    factory :executive do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::EXECUTIVE)
      end
    end


    factory :gt_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::GT_HEAD)
      end
    end

    factory :export do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::EXPORT)
      end
    end

    factory :dc_incharge do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_INCHARGE)
      end
    end

    factory :dc_ph_regional_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_PH_REGIONAL_HEAD)
      end
    end

    factory :dc_ph_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_PH_HEAD)
      end
    end

    factory :ph_incharge do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::PH_INCHARGE)
      end
    end

    factory :dc_executive do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::DC_EXECUTIVE)
      end
    end

    factory :ph_executive do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::PH_EXECUTIVE)
      end
    end

    factory :functional_coordinators do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::FUNCTIONAL_COORDINATOR)
      end
    end

    factory :product_coordinator do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::PRODUCT_COORDINATOR)
      end
    end

    factory :quality_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::QUALITY_HEAD)
      end
    end

    factory :quality_cluster_head do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::QUALITY_CLUSTER_HEAD)
      end
    end
    
    factory :quality_executive do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::QUALITY_EXECUTIVE)
      end
    end

    factory :nfi_po_approver do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::NFI_PO_APPROVER)
      end
    end

    factory :nfi_approver do
      after(:create) do |user|
        nfi_approver_role = create(:role, name: "nfi_approver",description: "NFI Buyer Approver")
        user.roles << Role.of_name(Role::Name::NFI_APPROVER)
      end
    end

    factory :admin_with_category do
      after(:create) do |user|
        user.roles << Role.of_name(Role::Name::CATEGORY)
        user.roles << Role.of_name(Role::Name::ADMIN)
      end
    end

  end
end