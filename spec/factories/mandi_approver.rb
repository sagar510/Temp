FactoryBot.define do
    factory :mandi_approver do
      association :mandi, factory: :mandi
      association :approver, factory: :user
    end
end