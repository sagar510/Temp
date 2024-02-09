require 'rails_helper'

RSpec.describe CaGateinItem, type: :model do
  let(:ca_gatein) { create(:ca_gatein) }
  let(:product) { create(:pomo) }
  let(:sku) { create(:sku_pomo) }

  describe 'associations' do
    it { should belong_to(:ca_gatein_farmer) }
    it { should belong_to(:product) }
    it { should belong_to(:sku) }
    it { should belong_to(:ca_gatein_grading).optional }
    it { should have_many(:ca_gatein_graded_lots).through(:ca_gatein_grading) }
    it { should have_one(:ca_gatein).through(:ca_gatein_farmer) }
    it { should have_one(:ca_farmer_token).through(:ca_gatein_farmer) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(CaGateinItem::Status.all) }
    it { should validate_presence_of(:units) }
    it { should validate_numericality_of(:units).is_greater_than(0) }
    it { should validate_presence_of(:weight) }
    it { should validate_numericality_of(:weight).is_greater_than(0) }
  end

  describe 'callbacks' do
    it 'does not allow destruction of a graded item' do
      graded_item = create(:ca_gatein_item, ca_gatein: ca_gatein, status: CaGateinItem::Status::GRADED)
      expect { graded_item.destroy }.to raise_error("Cannot remove a gatein item which is already graded")
    end
  end

  describe 'methods' do
    describe '.create_many!' do
      it 'creates multiple CaGateinItem records' do
        ca_gatein_farmer = create(:ca_gatein_farmer, ca_gatein: ca_gatein)
        items = [{ product_id: product.id, sku_id: sku.id, status: CaGateinItem::Status::TO_BE_GRADED, units: 10, weight: 50.0 },
                 { product_id: product.id, sku_id: sku.id, status: CaGateinItem::Status::TO_BE_GRADED, units: 5, weight: 25.0 }]
        expect {
          CaGateinItem.create_many!(items, ca_gatein_farmer.id)
        }.to change(CaGateinItem, :count).by(2)
      end
    end

    describe '.update_many!' do
      it 'updates multiple CaGateinItem records' do
        item = create(:ca_gatein_item, status: CaGateinItem::Status::TO_BE_GRADED, units: 10, weight: 50.0)
        items_to_update = [{ id: item.id, status: CaGateinItem::Status::GRADED, units: 8, weight: 40.0 }]
        CaGateinItem.update_many!(items_to_update)
        item.reload
        expect(item.status).to eq(CaGateinItem::Status::GRADED)
        expect(item.units).to eq(8)
        expect(item.weight).to eq(40.0)
      end
    end
  end
end
