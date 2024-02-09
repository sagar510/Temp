FactoryBot.define do
  factory :partner do
    name {Faker::Name.first_name}
    phone_number {Faker::PhoneNumber.unique.cell_phone}
    location {build(:partner_location)}
    roles {[Partner::Role::FARMER]}

    factory :farmer do
      roles {[Partner::Role::FARMER]}
      
      factory :farmer_with_kyc_and_bank_detail do
        after(:create) do |farmer|
          create :kyc_doc, partner: farmer
          create :bank_detail, partner: farmer
        end
      end
    end

    factory :supplier do
      roles {[Partner::Role::SUPPLIER]} 
    end

    factory :service_provider do
      roles {[Partner::Role::SERVICE_PROVIDER]}
    end

    factory :transporter do
      roles {[Partner::Role::TRANSPORTER]}

      factory :transporter_with_kyc_and_bank_detail do
        after(:create) do |transporter|
          create :kyc_doc, partner: transporter
          create :bank_detail, partner: transporter
        end
      end
    end

    factory :grader do
      roles {[Partner::Role::GRADER]}
    end

    factory :multi_role_partner do
      roles {[Partner::Role::FARMER, Partner::Role::SUPPLIER, Partner::Role::GRADER]}
    end
  end
  factory :other, class: Partner do
    name {Faker::Name.first_name}
    phone_number {Faker::PhoneNumber.unique.cell_phone}
    roles {[Partner::Role::TRANSPORTER]}
    factory :other_with_kyc_and_bank_detail do
      after(:create) do |partner|
        create :kyc_doc, partner: partner
        create :bank_detail, partner: partner
      end
    end
  end
end
