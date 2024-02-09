# == Schema Information
#
# Table name: packaging_types
#
#  id                :bigint           not null, primary key
#  name              :string(255)      not null
#  code              :string(255)      not null
#  empty_weight      :float(24)
#  capacity          :float(24)
#  cost_per_unit     :float(24)
#  other_cost        :float(24)
#  total_cost_per_kg :float(24)        default(0.0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'
RSpec.describe PackagingType, type: :model do
  context 'ActiveRecord associations and validations' do
    it { should have_many(:lots) }
    it { should have_many(:purchase_items) }
    it { should have_many(:packaging_output_lots).class_name('Qr::PackagingOutputLot').with_foreign_key(:packaging_type_id) }

    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:code) }
  end

  context 'callback' do
    it 'block destroy' do
      # create(:dc_lot)
      # fm = PackagingType.find_by_code("CRAT")
      
      # expect(fm.lots.size).to eq(1)
      # expect { fm.destroy }.to raise_error
    end
  end
end
