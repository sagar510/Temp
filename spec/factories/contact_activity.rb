FactoryBot.define do
  factory :ca_o1, class: ContactActivity do
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::OUTGOING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    duration {40}
    billsec {20}
    circle {"MH"}
    status {"ANSWER"}
    agentname {"Raju"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_o2, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::OUTGOING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    duration {10}
    billsec {0}
    circle {"KA"}
    status {"BUSY"}
    agentname {"Raju"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_o3, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::OUTGOING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    duration {20}
    billsec {10}
    circle {"AP"}
    status {"ANSWER"}
    agentname {"Ravi"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_o4, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::OUTGOING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    duration {20}
    billsec {0}
    circle {"TS"}
    status {"BUSY"}
    agentname {"Ravi"}
    kaleyra_id {Faker::Code.imei}
  end


  factory :ca_i1, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::INCOMING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    billsec {25}
    circle {"MH"}
    status {"ANSWER"}
    agentname {"Raju"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_i2, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::INCOMING}
    starttime {DateTime.new(2020,10,9,10,10,10)}
    endtime {DateTime.new(2020,10,9,10,10,50)}
    billsec {0}
    circle {"KA"}
    status {"BUSY"}
    agentname {"Raju"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_i3, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::INCOMING}
    starttime {DateTime.new(2020,10,9,10,10,10)}
    endtime {DateTime.new(2020,10,9,10,10,50)}
    billsec {15}
    circle {"AP"}
    status {"ANSWER"}
    agentname {"Ravi"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_i4, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::INCOMING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    billsec {0}
    circle {"TS"}
    status {"BUSY"}
    agentname {"Ravi"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_i5, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    receiver {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::INCOMING}
    starttime {DateTime.new(2020,10,10,10,10,10)}
    endtime {DateTime.new(2020,10,10,10,10,50)}
    billsec {0}
    circle {"TS"}
    status {"BUSY"}
    agentname {"Ravi"}
    kaleyra_id {Faker::Code.imei}
  end

  factory :ca_m1, class: ContactActivity do
    before(:create) do |job|
      job.caller = Faker::PhoneNumber.cell_phone_in_e164 
    end
    bridgenumber {Faker::PhoneNumber.cell_phone_in_e164 }
    call_type {ContactActivity::Type::MISSED}
    starttime {DateTime.new(2020,10,11,10,10,10)}
    endtime {DateTime.new(2020,10,11,10,10,50)}
    billsec {0}
    circle {"TS"}
    kaleyra_id {Faker::Code.imei}
  end

end