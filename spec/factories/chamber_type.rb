FactoryBot.define do
  factory :chamber_type do
    is_primary {true}
    name {"Operations Area"}
    # short_code {"OPT_AREA"}
    short_code { SecureRandom.hex(3).upcase }
    rank {1}
    factory :zone do
      is_primary {false}
      name {"Zone"}
      short_code {"Zone"}
      rank {2}
    end
  end
end
