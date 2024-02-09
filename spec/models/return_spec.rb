# == Schema Information
#
# Table name: returns
#
#  id                 :bigint           not null, primary key
#  sale_order_item_id :bigint           not null
#  product_issue_id   :bigint           not null
#  weight             :float(24)        not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe Return, type: :model do

  context 'ActiveRecord associations' do
    it { should belong_to(:sale_order_item) }
    it { should belong_to(:product_issue) }
  end
  
  describe "ActiveModel validations" do
    it { should validate_presence_of(:product_issue_id) }
    # it { should validate_uniqueness_of(:product_issue_id).scoped_to(:sale_order_item_id).case_insensitive }
    it { should validate_numericality_of(:weight).is_greater_than_or_equal_to(0) }
  end

end
