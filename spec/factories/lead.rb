FactoryBot.define do
  factory :ka_ac_1, class: Lead do
    phone_number {Faker::PhoneNumber.cell_phone_in_e164 }
    state {"Karnataka"}
    status {"Prospective"}
    disposition {"Call back"}
    crop {"Pomegranate"}
  end

  factory :ka_cl_1, class: Lead do
    phone_number {Faker::PhoneNumber.cell_phone_in_e164 }
    state {"Karnataka"}
    status {"Dead"}
    disposition {"Call back"}
    crop {"Pomegranate"}
  end

  factory :mh_ac_1, class: Lead do
    phone_number {Faker::PhoneNumber.cell_phone_in_e164 }
    state {"Maharashtra"}
    status {"Buyer Review"}
    disposition {"Call back"}
    crop {"Pomegranate"}
  end

  factory :mh_cl_1, class: Lead do
    phone_number {Faker::PhoneNumber.cell_phone_in_e164 }
    state {"Maharashtra"}
    status {"Closed"}
    disposition {"Call back"}
    crop {"Pomegranate"}
  end

end