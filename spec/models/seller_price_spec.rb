# == Schema Information
#
# Table name: seller_prices
#
#  id                   :bigint           not null, primary key
#  sku_id               :bigint           not null
#  dc_id                :bigint           not null
#  price                :bigint           not null
#  price_date           :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require 'rails_helper'

RSpec.describe SellerPrice, type: :model do


  context 'ActiveRecord associations' do
    it { should belong_to(:sku) }
    it { should belong_to(:dc) }
    it { should have_many(:lots) }

  end

  context 'method tests' do
    it 'get_target_price' do
      sp1 = create :previous_seller_price
      expect(SellerPrice.get_target_price(sp1.dc_id, sp1.sku_id, DateTime.current)).to eq(sp1.price)
    end
    it 'get_upcoming_date' do
      sp1 = create :upcoming_seller_price
      expect(SellerPrice.get_upcoming_date(sp1.sku.product)).to eq(sp1.price_date.to_date)
    end
    it 'update_seller_prices' do
      sku = create :sku_pomo
      dc = create :hyd_dc
      params = [{"sku_id"=>sku.id.to_s,"dc_id"=>dc.id.to_s, "price"=>"300"}]
      date = Faker::Time.between(from: DateTime.now - 1, to: DateTime.now).to_date
      SellerPrice.update_prices(params, date, sku.product.id.to_s)
      expect(SellerPrice.all.length).to eq(1)
      SellerPrice.update_prices(params, date, sku.product.id.to_s)
      expect(SellerPrice.all.length).to eq(1)
      date = Faker::Time.between(from: DateTime.now + 1, to: DateTime.now + 10).to_date
      SellerPrice.update_prices(params, date, sku.product.id.to_s)
      expect(SellerPrice.all.length).to eq(2)
    end
    it 'get_prices_data' do
      sp1 = create :previous_seller_price
      lot = create :dc_lot
      sp1.sku.lots << lot
      result = {sp1.sku => {sp1.dc.name => sp1.price} }
      expect(SellerPrice.get_prices_data([sp1.dc], sp1.sku.product, SellerPrice::Type::CURRENT)).to include(result)
    end
  end
end
