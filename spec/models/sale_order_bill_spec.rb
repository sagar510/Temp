# == Schema Information
#
# Table name: sale_order_bills
#
#  id            :bigint           not null, primary key
#  number        :integer
#  sale_order_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe SaleOrderBill, type: :model do
  context 'factory validation tests' do
    it "sale order bill has a valid factory" do
      expect(build(:sale_order_bill)).to be_valid
    end
  end

  context 'association test' do
    it "has_one sale_order" do
      should belong_to(:sale_order)
    end
  end

  context 'basic validations' do
    it { expect(build :sale_order_bill).to validate_presence_of(:sale_order_id) }
  end
end
