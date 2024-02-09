
require 'rails_helper'


RSpec.describe Chamber, type: :model do

  describe "ActiveRecord Associations" do
    it { should have_many(:packaging_processes).class_name('Qr::PackagingProcess').with_foreign_key(:chamber_id) }
  end

  context 'scope tests' do
    it 'validates scopes' do
      dc = create :hyd_dc
      Chamber.destroy_all
      chamber_1 = create :chamber, dc: dc
      chamber_2 = create :zone_chamber, dc: dc

      expect(Chamber.new.dc_primary_chamber(dc.id)).to eq(chamber_1)
      expect(Chamber.of_dc(dc.id)).to eq([chamber_1, chamber_2])
    end
  end
end