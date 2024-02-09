FactoryBot.define do
    factory :sampling do
        user
        sampling_time {Faker::Date.between(from: 10.days.ago, to: Date.today)}
        lot 
        partial_weight {Faker::Number.number(digits: 1)}
        average_weight {Faker::Number.between(from: 180, to: 200)/10}
    end

end