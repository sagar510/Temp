# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string(255)
#  phone_number           :string(255)
#  name                   :string(255)
#  whatsapp_number        :string(255)
#  is_valid_number        :boolean          default(TRUE)
#  active                 :boolean          default(TRUE)
#  roles                  :text(65535)
#  state                  :string(255)      default("Karnataka")
#
require 'rails_helper'

RSpec.describe User, type: :model do

  it "has a valid factory" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  describe "ActiveRecord Associations" do
    it { should have_many(:created_packaging_processes).class_name('Qr::PackagingProcess').with_foreign_key(:created_by) }
    it { should have_many(:updated_packaging_processes).class_name('Qr::PackagingProcess').with_foreign_key(:updated_by) }
  end

  it "do not create user with same phone number" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    user2.phone_number = user1.phone_number
    expect { user2.save! }.to raise_error
  end

  it "do not create user with same username" do
    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)
    user2.username = user1.username
    expect { user2.save! }.to raise_error
  end

  it "validate of_role " do
    user1 = FactoryBot.create(:admin_user)
    user_ids = User.of_role(Role::Name::ADMIN).map(&:id)
    expect(user_ids).to include(user1.id)
  end

  context "model methods test" do
    it "user: finance_executive?" do
      user1 = FactoryBot.create(:finance_executive_user)
      user2 = FactoryBot.create(:sales_executive_user)

      expect(user1.finance_executive?).to eq(true)
      expect(user2.finance_executive?).to eq(false)
    end
    it "user: logistic_approver?" do
      user1 = FactoryBot.create(:logistic_approver_user)
      expect(user1.logistic_approver?).to eq(true)
      expect(user1.logistics_manager?).to eq(false)
    end

    it "user: logistics_manager?" do
      user1 = FactoryBot.create(:logistics_manager_user)
      expect(user1.logistic_approver?).to eq(false)
      expect(user1.logistics_manager?).to eq(true)
    end

    it "user: product_head?" do
      user1 = FactoryBot.create(:product_head)
      expect(user1.logistics_manager?).to eq(false)
      expect(user1.product_head?).to eq(true)
    end

    it "user: slack_channel" do 
      user = FactoryBot.create(:admin_user)
      expect(user.slack_channel).to eq("test123")
    end
  end
end