require 'rails_helper'

RSpec.describe MandiNfiPackagingItem, type: :model do
  let(:mandi) { create(:mandi) }
  let(:packaging_item) { create(:nfi_packaging_item) }

  describe 'associations' do
    it { should belong_to(:nfi_packaging_item).class_name('Nfi::PackagingItem').with_foreign_key(:nfi_packaging_item_id) }
    it { should belong_to(:mandi).class_name('Mandi').with_foreign_key(:mandi_id) }
  end

  describe 'validations' do
    subject { build(:mandi_nfi_packaging_item, mandi: mandi, nfi_packaging_item: packaging_item) }

    it { should validate_uniqueness_of(:nfi_packaging_item_id).scoped_to(:mandi_id) }
    it { should validate_presence_of(:rate) }
    it { should validate_numericality_of(:rate).is_greater_than(0) }

    it 'checks for uniqueness of packaging_item and mandi' do
      mandi_nfi_packaging_item1 = create(:mandi_nfi_packaging_item)
      mandi_nfi_packaging_item2 = create(:mandi_nfi_packaging_item)
      expect(mandi_nfi_packaging_item2).to be_an_instance_of(MandiNfiPackagingItem)
      expect do
        create(:mandi_nfi_packaging_item, mandi_id: mandi_nfi_packaging_item1.mandi_id, nfi_packaging_item_id: mandi_nfi_packaging_item1.nfi_packaging_item_id)
      end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Nfi packaging item has already been taken/)
    end

    it 'checks for rate less than 0' do
      mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item)
      expect(mandi_nfi_packaging_item.update(rate: 10)).to be true
      expect { mandi_nfi_packaging_item.update!(rate: -10) }.to raise_error(ActiveRecord::RecordInvalid)
    end
    
  end

  describe 'scopes' do
    describe '.packaging_items_of_mandi_dc' do
      it 'returns mandi_nfi_packaging_items of the specified dc' do
        dc_id = mandi.dc_id
        mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, mandi: mandi)
        expect(described_class.packaging_items_of_mandi_dc(dc_id)).to eq([mandi_nfi_packaging_item])
      end

      it 'does not return mandi_nfi_packaging_items of other dcs' do
        other_dc = create(:dc)
        mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, mandi: mandi)
        expect(described_class.packaging_items_of_mandi_dc(other_dc.id)).to be_empty
      end
    end

    describe '.of_packaging_item' do
      it 'returns mandi_nfi_packaging_items of the specified packaging item' do
        packaging_item_id = packaging_item.id
        mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, nfi_packaging_item: packaging_item)
        expect(described_class.of_packaging_item(packaging_item_id)).to eq([mandi_nfi_packaging_item])
      end

      it 'does not return mandi_nfi_packaging_items of other packaging items' do
        other_packaging_item = create(:nfi_packaging_item)
        mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, nfi_packaging_item: packaging_item)
        expect(described_class.of_packaging_item(other_packaging_item.id)).to be_empty
      end
    end

    describe '.packaging_items_of_satellite_dc' do
      it 'returns mandi_nfi_packaging_items of the satellite dc' do
        packaging_item_id = packaging_item.id
        satellite_cc = create(:dc, dc_type: Dc::Type::SATELLITE)
        mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, nfi_packaging_item: packaging_item)
        mandi_satellite_cc = create(:mandi_satellite_cc, mandi: mandi_nfi_packaging_item.mandi, dc: satellite_cc )
        expect(described_class.packaging_items_of_satellite_dc(satellite_cc.id)).to eq([mandi_nfi_packaging_item])
      end
    end
  end

  describe 'methods' do
    it 'calculates_effective_rate for NA GST' do
      mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, gst: -1)
      expect(mandi_nfi_packaging_item.effective_rate).to eq(mandi_nfi_packaging_item.rate)
    end

    it 'calculates_effective_rate for other GST' do
      mandi_nfi_packaging_item = create(:mandi_nfi_packaging_item, gst: 5, rate: 12)
      expect(mandi_nfi_packaging_item.effective_rate).to eq(12.6)
    end
  end
end
