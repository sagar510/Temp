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
FactoryBot.define do
  factory :role do
    name { "MyString" }
    description { "MyText" }
  end
end
