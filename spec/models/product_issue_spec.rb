# == Schema Information
#
# Table name: product_issues
#
#  id         :bigint           not null, primary key
#  product_id :bigint
#  issue      :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe ProductIssue, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:product_issue_pomo)).to be_valid
  end

  it "has unique issues for a product" do
    pi1 = FactoryBot.create(:product_issue_pomo)
    pi2 = FactoryBot.create(:product_issue_pomo)
    pi2.issue = pi1.issue
    pi2.product_id = pi1.product_id
    expect { pi2.save! }.to raise_error
  end

end
