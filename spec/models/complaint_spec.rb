# == Schema Information
#
# Table name: complaints
#
#  id                 :bigint           not null, primary key
#  sale_order_item_id :bigint           not null
#  quality_issue_id   :bigint
#  description        :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe Complaint, type: :model do

  context "valid factory test" do 
    it { expect(create(:complaint)).to be_valid }
  end

  context "ActiveRecord associations" do
    it { should belong_to(:sale_order_item) }
    it { should belong_to(:quality_issue).optional }
  end
end
