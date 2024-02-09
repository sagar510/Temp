FactoryBot.define do
  factory :bank_detail, class: BankDetail do
    partner factory: :farmer
    account_number { Faker::Number.number(digits: 11) }
    ifsc { Faker::Alphanumeric.alphanumeric(number: 11) }
    status { BankDetail::Status::UNVERIFIED }
    before(:create) do |bank_detail|
      bank_detail.account_number_confirmation = bank_detail.account_number
    end
  end
end