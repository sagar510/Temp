FactoryBot.define do
  factory :kyc_doc, class: KycDoc do
    partner factory: :farmer
    doc_type { KycDoc::DocType::AADHAR }
    status { KycDoc::Status::UNVERIFIED }
  end
end