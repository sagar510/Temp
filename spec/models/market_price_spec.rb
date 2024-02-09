# == Schema Information
#
# Table name: market_prices
#
#  id         :bigint           not null, primary key
#  dc_id      :bigint
#  sku_id     :bigint
#  user_id    :bigint
#  price      :float(24)
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'
require_relative '../support/devise'


RSpec.describe MarketPrice, type: :model do
  context 'ActiveRecord associations' do
    it { should belong_to(:sku) }
    it { should belong_to(:dc) }
    it { should belong_to(:user)}
  end

  context "model methods test" do
    it "material_grade" do
      p1 = create :pomo
      expect(MarketPrice.fetch_sku_location_wise(Dc::Type::CC, p1.id,"2020-12-12")).to eq([])
    end
  end

end
