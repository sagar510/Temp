FactoryBot.define do
  factory :payment_request_approver do
    payment_request
    approver factory: :buyer_user
  end
end