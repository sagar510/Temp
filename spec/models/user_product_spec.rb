# == Schema Information
#
# Table name: user_products
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  product_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe UserProduct, type: :model do
end
