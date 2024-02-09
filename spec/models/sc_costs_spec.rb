require 'rails_helper'
require 'csv'
require 'date'

RSpec.describe ScCost, type: :model do
  describe 'validations' do
    subject { FactoryBot.build(:sc_cost) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
   end

  describe 'associations' do
    it { should belong_to(:product_category) }
    it { should belong_to(:cost_head) }
  end

  describe "test data" do
    before do
      @sccost = create(:sc_cost)
      @product_category1 = create(:pomo_product_category)
      @cost_head1     = create(:fruit_ch)
    end

    describe ".apply_filters" do
      it "returns filtered models" do
        expect(ScCost.of_product_category(@sccost.product_category.id).count).to eq(1)
        expect(ScCost.of_cost_head(@sccost.cost_head.id).count).to eq(1)
      end
    end

    describe '.create_from_csv' do
      let(:current_user) { FactoryBot.create(:user) }
      let(:start_date) { Time.now.strftime("%Y-%m-%d")}
      context 'when the CSV file is valid' do
      let(:file) { fixture_file_upload('spec/template.csv', 'text/csv') }

        it 'creates new sc_costs records and updates it' do
          expect do
            errors = ScCost.create_from_csv(file, start_date, current_user)
            expect(errors).to be_empty
          end.to change(ScCost, :count).by(1)
          expect do
            errors = ScCost.create_from_csv(file, start_date, current_user)
            expect(errors).to be_empty
          end.to change(ScCost, :count).by(0)
        end
      end
    end
    
    describe ".get_prices_data" do
      let!(:pc1) { create(:pomo_product_category) }
      let!(:ch1) { create(:fruit_ch, pnl_category: "CM1", is_pnl_auto_calculated: false) }
      let!(:sc_cost1) { create(:sc_cost, product_category: pc1, cost_head: ch1, price: 10) }
    
      context "when given valid product categories and cost heads" do
        it "returns a hash with current prices for the given product categories and cost heads" do
          product_categories = [pc1]
          cost_heads = [ch1]
          expected_result = {
            pc1.name => { ch1.name => sc_cost1.price}
          }
          expect(described_class.get_prices_data(product_categories, cost_heads)).to eq(expected_result)
        end
      end
    end
  end
end