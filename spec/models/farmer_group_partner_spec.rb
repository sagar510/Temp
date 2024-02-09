# == Schema Information
#
# Table name: farmer_group_partners
#
#  id              :bigint           not null, primary key
#  farmer_group_id :bigint
#  partner_id      :bigint
#  source          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe FarmerGroupPartner, type: :model do
end
