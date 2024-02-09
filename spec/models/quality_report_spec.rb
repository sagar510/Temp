# == Schema Information
#
# Table name: quality_reports
#
#  id            :bigint           not null, primary key
#  user_id       :bigint
#  report_type   :integer          default(0)
#  store_details :json
#  item_weight   :json
#  item_quality  :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  source        :boolean
#  shipment_id   :bigint
#  sale_order_id :bigint
#  customer_id   :bigint
#
require 'rails_helper'

RSpec.describe QualityReport, type: :model do
  
  describe "ActiveModel validations" do
    # Basic validations
    it { should validate_presence_of(:customer) }
    it { should validate_presence_of(:report_type) }
    
  end

  context 'ActiveRecord associations' do
    it { should belong_to(:user) }
  end
end
