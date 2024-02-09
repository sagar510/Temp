FactoryBot.define do
  factory :ca_farmer_token do
    association :ca_gatein_farmer, factory: :ca_gatein_farmer
    association :dc, factory: :dc
    token { "C-#{Faker::Alphanumeric.alphanumeric(number: 4)}-#{Faker::Alphanumeric.alphanumeric(number: 2)}" }
    is_cancelled { false }
    cancellation_reason { nil }
    comment { nil }
    association :cancelled_by, factory: :user
    cancelled_on { nil }

    trait :cancelled do
      is_cancelled { true }
      cancellation_reason { "Reason for cancellation" }
      cancelled_by { association(:user) }
      cancelled_on { Time.now }
    end
  end
end
