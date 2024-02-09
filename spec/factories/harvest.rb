FactoryBot.define do
    factory :child_harvest, class: Harvest do
      purchase_order factory: :farmer_purchase_order
      harvest_date {0.day.ago}
      harvest_day {2}
    end

end
  
  
  