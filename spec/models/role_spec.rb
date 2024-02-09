# == Schema Information
#
# Table name: roles
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Role, type: :model do
  
  context 'ActiveRecord associations' do
    it { should have_many(:user_roles) }
    it { should have_many(:users) }
  end
  
  describe "ActiveModel validations" do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:name).in_array(Role::Name::ALL) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end


end
