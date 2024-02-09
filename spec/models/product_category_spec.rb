require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  it "has a valid factory" do
    expect(create(:pomo_product_category)).to be_valid
    expect(create(:orange_product_category)).to be_valid
    expect(create(:grapes_product_category)).to be_valid
    expect(create(:kinnow_product_category)).to be_valid
  end

  context "call back" do
    it "on create will map to all partner material" do
      orange_product_category = create(:orange_product_category)
      packaging_item = create(:nfi_packaging_item, is_partner_material: true)
      expect(packaging_item.packaging_item_product_categories.count).to eq(1)
      pomo_product_category = create(:pomo_product_category)
      expect(packaging_item.packaging_item_product_categories.count).to eq(2)
    end
  end
  
end
