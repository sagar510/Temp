FactoryBot.define do

  sequence(:unique_short_code) do |n|
    code = nil
    loop do
      code = "#{Faker::Name.first_name.upcase}_#{n}"
      break unless Dc.exists?(short_code: code)
      n += 1
    end
    code
  end


  factory :dc, class: Dc do
    name {Faker::Name.first_name}
    location factory: :location
    dc_type {Dc::Type::DC}
    micro_pocket factory: :micro_pocket
    short_code { generate(:unique_short_code) }
    status {Dc::Status::ACTIVE}
    before(:create) do |dc|
      create(:chamber_type)
    end
    factory :hyd_dc do
      name {"Hyderabad"}
      dc_type {Dc::Type::DC}
      location factory: :hyd_dc_location
      short_code { generate(:unique_short_code) }
      before(:create) do |dc|
        create(:chamber_type)
      end
    end
    factory :ph_dc do
      name {"new ph"}
      dc_type {Dc::Type::CC}
      location factory: :hyd_dc_location
      short_code { generate(:unique_short_code) }
      before(:create) do |dc|
        create(:chamber_type)
      end
    end
    factory :b2r_bangalore_dc do
      name {"B2R Bangalore"}
      dc_type {Dc::Type::DC}
      subsidiary_type {Dc::SubsidiaryType::B2R}
      location factory: :hyd_dc_location
      short_code { generate(:unique_short_code) }
      before(:create) do |dc|
        create(:chamber_type)
      end
    end
  end

  factory :dc_cdc, class: Dc do
    name {Faker::Name.first_name}
    is_central {true}
    micro_pocket factory: :micro_pocket
    short_code { generate(:unique_short_code) }
    status {Dc::Status::ACTIVE}
    before(:create) do |dc|
      create(:chamber_type)
    end
  end

  factory :dc_mandi, class: Dc do
    name {"Jadcherla"}
    dc_type {Dc::Type::MANDI}
    location factory: :hyd_dc_location
    micro_pocket factory: :micro_pocket
    status {Dc::Status::ACTIVE}
    short_code { generate(:unique_short_code) }
    before(:create) do |dc|
      create(:chamber_type)
    end
  end
end
