require 'rails_helper'

RSpec.describe CaGatein, type: :model do
  let(:hyd_dc) { create(:hyd_dc) }
  let(:dc) { create(:dc) }
  
  describe 'validations' do
    it { should validate_presence_of(:purchase_type).with_message('can\'t be blank') }
    it { should validate_presence_of(:model).with_message('can\'t be blank') }
    it { should validate_presence_of(:inward_type).with_message('can\'t be blank') }
    it { should validate_inclusion_of(:purchase_type).in_array(CaGatein::PurchaseType.all) }
    it { should validate_inclusion_of(:model).in_array(CaGatein::Model.all) }
    it { should validate_inclusion_of(:inward_type).in_array(CaGatein::InwardType.all) }
  end

  describe 'associations' do
    it { should belong_to(:dc) }
    it { should belong_to(:user) }
    it { should have_many(:ca_gatein_farmers) }
    it { should have_many(:ca_farmer_tokens).through(:ca_gatein_farmers) }
    it { should have_many(:ca_gatein_items).through(:ca_gatein_farmers) }
  end

  describe 'methods' do
    describe 'create_gatein_with_items' do
      let(:user) { create(:user) }
      let(:dc) { create(:dc) }
      let(:ca_gatein_params) { attributes_for(:ca_gatein) }
      let(:other_info) { { user_id: user.id, ca_gatein_farmers: [] } }

      context 'when the DC is not of type PH' do
        it 'raises a runtime error with specific message' do
          ca_gatein_params[:dc_id] = dc.id
          expect {
            CaGatein.create_gatein_with_items(ca_gatein_params, other_info)
          }.to raise_error(RuntimeError, 'Only PHs are allowed for ca gateins')
        end
      end

      context 'when the DC is of type PH' do
        it 'creates a new CaGatein record with associated farmers, items, and tokens' do
          dc.update(dc_type: Dc::Type::CC)
          ca_gatein_params[:dc_id] = dc.id
          expect {
            CaGatein.create_gatein_with_items(ca_gatein_params, other_info)
          }.to change(CaGatein, :count).by(1)
        end
      end
    end

    describe '#is_any_item_graded?' do
      let(:ca_gatein) { create(:ca_gatein) }
  
      context 'when no items are graded' do
        it 'returns false' do
          expect(ca_gatein.is_any_item_graded?).to be_falsey
        end
      end
  
      context 'when some items are graded' do
        it 'returns true' do
          create(:ca_gatein_item, ca_gatein: ca_gatein, status: CaGateinItem::Status::GRADED)
          expect(ca_gatein.is_any_item_graded?).to be_truthy
        end
      end
    end
  end
end
