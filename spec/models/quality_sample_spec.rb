# == Schema Information
#
# Table name: quality_samples
#
#  id                 :bigint           not null, primary key
#  quality_report_id  :bigint
#  sale_order_item_id :bigint
#  lot_id             :bigint
#  sku_id             :bigint
#  net_weight         :float(24)
#  fruit_count        :integer
#  quality_data       :json
#  input_data         :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe QualitySample, type: :model do
end
