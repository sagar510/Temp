FactoryBot.define do
  factory :purchase_order_user do
    factory :field_executive_purchase_oder_user do
      role_id { Role.of_name(Role::Name::FIELD_EXEC).first.id }
      user factory: :field_executive_user
    end

    factory :buyer_purchase_oder_user do
      role_id { Role.of_name(Role::Name::BUYER).first.id }
      user factory: :buyer_user
    end
  end
end


