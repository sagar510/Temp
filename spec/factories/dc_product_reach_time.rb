# Table name: dc_product_reach_times
#
# id            bigint      
# days_to_reach int         
# dc_id         bigint      
# product_id    bigint      
# created_at    datetime(6) 
# updated_at
#
FactoryBot.define do
    factory :dc_product_reach_time do
        dc factory: :hyd_dc
        product factory: :pomo
        days_to_reach {3}
    end
end

  