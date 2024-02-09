FactoryBot.define do
  factory :velynk_config do
    name { Faker::Lorem.word }
    value { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    data_type { VelynkConfig::DataType::STRING }
  end
end
  