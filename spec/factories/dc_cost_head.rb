FactoryBot.define do
    factory :dc_cost_head, class: DcCostHead do
        dc factory: :dc
        cost_head factory: :fruit_ch
    end
end