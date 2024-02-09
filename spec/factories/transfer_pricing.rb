FactoryBot.define do
  factory :transfer_pricing do  #base. Create Bots with shipments
    setter { create :admin_user }
    rejecter { create :admin_user }
    approver { create :admin_user }
    transfer_type {TransferPricing::TransferType::FIXED}
  end
end