FactoryBot.define do
  factory :location do
    full_address {Faker::Address.full_address}
    lat {15.3173}
    lng {75.7139}
    state {"Karnataka"}
    district {"Mysore"}

    factory :hyd_dc_location do
      state {"Telangana"}
      district {"Medchal"}
      full_address {"Devaryamjal, Shamirpet, Medchal, Telangana - 500078"}
    end


    factory :farm_location do
      full_address {"Mysore - 570005"}
    end

    factory :partner_location do
      full_address {"Udupi - 570006"}
    end
  end
end