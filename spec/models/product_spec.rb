# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Product, type: :model do

  describe "ActiveRecord Associations" do
    it { should have_many(:packaging_processes).class_name('Qr::PackagingProcess').with_foreign_key(:product_id) }
  end

  it "validates presence of name" do
    product = FactoryBot.build(:product)
    product.code = "temp"
    expect { product.save! }.to raise_error
  end

  it "validates presence of code" do
    product = FactoryBot.build(:product)
    product.name = "temp"
    expect { product.save! }.to raise_error
  end

  it "do not create product with same name" do
    product1 = FactoryBot.create(:pomo)
    product2 = FactoryBot.create(:orange)
    product2.name = product1.name
    expect { product2.save! }.to raise_error
  end

  it "do not create product with same code" do
    product1 = FactoryBot.create(:pomo)
    product2 = FactoryBot.create(:orange)
    product2.code = product1.code
    expect { product2.save! }.to raise_error
  end

end
