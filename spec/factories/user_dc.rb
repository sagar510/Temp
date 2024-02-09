FactoryBot.define do
    factory :user_dc, class: UserDc do
        dc factory: :dc
        user factory: :user
    end
end