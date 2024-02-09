FactoryBot.define do
  factory :quality_report do
    user factory: :dc_executive_user
    report_type {1}
    shipment factory: :dc_to_dc_shipment

    factory :source_quality_report do
      source {1}
    end

    factory :product_quality_report do
      source {0}
    end

    after(:build) do |quality_report|
      quality_report.summary.attach(
        io: StringIO.new("Mock PNG content"),
        filename: 'mock_image.png',
        content_type: 'image/png'
      )
    end
  end
end
