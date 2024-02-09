require 'rails_helper'

RSpec.describe Mandi, type: :model do
    describe 'associations' do
        it { should belong_to(:dc) }
        it { should belong_to(:field_executive).optional(true) }
        it { should have_many(:mandi_skus) }
        it { should have_many(:skus).through(:mandi_skus) }
        it { should have_many(:mandi_products) }
        it { should have_many(:products).through(:mandi_products) }
        it { should have_many(:grader_mandis) }
        it { should have_many(:mandi_approvers) }
        it { should have_many(:approvers).through(:mandi_approvers) }
        it { should have_many(:auction_user_mandis).dependent(:destroy) }
        it { should have_many(:auction_users).through(:auction_user_mandis) }
        it { should have_many(:auctioneers) }
        it { should have_many(:mandi_farmer_charge_lists) }
        it { should have_many(:mandi_farmer_charge).through(:mandi_farmer_charge_lists) }
        it { should have_many(:mandi_customer_charge_lists) }
        it { should have_many(:mandi_customer_charge).through(:mandi_customer_charge_lists) }
        it { should have_many(:mandi_packaging_type_configs).dependent(:destroy) }
        it { should have_many(:mandi_pack_type_charges).dependent(:destroy) }
        it { should have_many(:mandi_sku_packaging_type_configs).dependent(:destroy) }
        it { should have_many(:mandi_nfi_packaging_items).dependent(:destroy) }
    end

    describe 'instance methods' do
        let(:mandi) { create(:mandi) }
    
        describe '#approver_names' do
          it 'returns names of associated approvers' do
            approver1 = create(:user, name: 'Approver 1')
            approver2 = create(:user, name: 'Approver 2')
            create(:mandi_approver, mandi: mandi, approver: approver1)
            create(:mandi_approver, mandi: mandi, approver: approver2)
    
            expect(mandi.approver_names).to match_array(['Approver 1', 'Approver 2'])
          end
        end
    end
    
end
