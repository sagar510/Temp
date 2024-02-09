# == Schema Information
#
# Table name: material_order_items
#
#  id                            :bigint           not null, primary key
#  lot_id                        :bigint
#  sale_order_item_id            :bigint
#  sku_id                        :bigint           not null
#  material_order_id             :bigint           not null
#  ordered_weight                :float(24)
#  ordered_units                 :integer
#  order_type                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  parent_material_order_item_id :bigint
#
require 'rails_helper'

RSpec.describe MaterialOrderItem, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  context 'method tests' do
    it 'create_many' do
      mois = []
      mo = create :mo_for_amo
      sku1 = create :sku_kinnow_72
      sku2 = create :sku_pomo
      expect(mois.count).to eq(0)
      moi_attrs = [{
        :ordered_weight=>100, 
        :average_weight=>10, 
        :sku_id=>sku1.id,
        :order_type => MaterialOrderItem::OrderType::KG,
        :price => 100
      },
      { 
        :ordered_weight=>144, 
        :average_weight=>12,
        :sku_id=>sku2.id,
        :order_type => MaterialOrderItem::OrderType::KG,
        :price => 200
      },
      {
        :ordered_units => 3,
        :average_weight => 10.0,
        :sku_id => sku1.id,
        :order_type => MaterialOrderItem::OrderType::UNIT,
        :price => 300
      }]

      mois = MaterialOrderItem.create_many(moi_attrs, mo.id)

      expect(mois.count).to eq(3)
      mois.each { |moi| expect(moi.material_order.id).to eq(mo.id) }
      expect(mois[2].ordered_weight).to eq(30.0)
      expect(mois[0].order_type).to eq(MaterialOrderItem::OrderType::KG)
      expect(mois[1].order_type).to eq(MaterialOrderItem::OrderType::KG)
      expect(mois[2].order_type).to eq(MaterialOrderItem::OrderType::UNIT)
      expect(mois[0].get_price).to eq(100)
      expect(mois[1].get_price).to eq(200)
      expect(mois[2].get_price).to eq(300)
    end

    it '.map_sku_and_weight' do
      mo = create :mo_for_amo
      sku = create :sku_pomo
      product = create :pomo_product_category
      moi_attrs = {
        :ordered_weight=>100, 
        :average_weight=>10, 
        :sku_id=>sku.id,
        :order_type => MaterialOrderItem::OrderType::KG,
        :price => 100
      }

      mois = MaterialOrderItem.create(moi_attrs)
      
      amo_exceptions_list = MaterialOrderItem.map_sku_and_weight(mois)
      expect(amo_exceptions_list).to eq([
              { sku: 'Pomegranate(200-300)', weight: 100.0 }
            ])
    end
  end
end
