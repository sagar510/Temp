FactoryBot.define do
  factory :ca_gatein_farmer do
    association :ca_gatein, factory: :ca_gatein
    association :farmer, factory: :farmer
  end
end
