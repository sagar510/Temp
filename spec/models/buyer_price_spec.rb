# == Schema Information
#
# Table name: buyer_prices
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

RSpec.describe BuyerPrice, type: :model do


  context 'ActiveRecord associations' do
    it { should belong_to(:sku) }
    it { should belong_to(:micro_pocket) }
    it { should have_many(:lots) }

  end

  context 'method tests' do
    it 'get_target_price' do
      sp1 = create :previous_buyer_price
      expect(BuyerPrice.get_target_price(sp1.micro_pocket_id, sp1.sku_id, DateTime.current)).to eq(sp1.price)
    end
    it 'get_upcoming_date' do
      sp1 = create :upcoming_buyer_price
      expect(BuyerPrice.get_upcoming_date(sp1.sku.product)).to eq(sp1.price_date.to_date)
    end
    it 'update_buyer_prices' do
      sku = create :sku_pomo
      micro_pocket = create :micro_pocket
      params = [{"sku_id"=>sku.id.to_s,"micro_pocket_id"=>micro_pocket.id.to_s, "price"=>"300"}]
      date = Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
      BuyerPrice.update_buyer_prices(params, date, sku.product.id.to_s)
      expect(BuyerPrice.all.length).to eq(1)
      BuyerPrice.update_buyer_prices(params, date, sku.product.id.to_s)
      expect(BuyerPrice.all.length).to eq(1)
      date = Faker::Time.between(from: DateTime.now + 1, to: DateTime.now + 10)
      BuyerPrice.update_buyer_prices(params, date, sku.product.id.to_s)
      expect(BuyerPrice.all.length).to eq(2)
    end
    it 'get_prices_data' do
      sp1 = create :previous_buyer_price
      lot = create :dc_lot
      sp1.sku.lots << lot
      result = {sp1.sku => {sp1.micro_pocket.micro_pocket => sp1.price} }
      expect(BuyerPrice.get_prices_data([sp1.micro_pocket], sp1.sku.product, BuyerPrice::Type::CURRENT)).to eq(result)
    end
  end
end
