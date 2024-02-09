# == Schema Information
#
# Table name: customer_locations
#
#  id             :bigint           not null, primary key
#  customer_id    :bigint           not null
#  location_id    :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :customer_location do
    customer { create(:customer_mt) }
    location { Location.create_from_address!({:full_address=>"Bangalore"}) }
  end
end
