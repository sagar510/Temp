# == Schema Information
#
# Table name: dcs
#
#  id               :bigint           not null, primary key
#  name             :string(255)
#  location_id      :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_central       :boolean          default(FALSE)
#  dc_type          :string(255)
#  short_code       :string(255)
#  notif_channel    :string(255)
#  micro_pocket_id  :bigint
#  rent_amount      :decimal
#  incharge_id      :bigint
#  is_active        :boolean
#  zoho_branch_id   :bigint
#  deactivated      :boolean
#  subsidiary_type  :string(255)
#  gstin            :string(255)

require 'rails_helper'

RSpec.describe Dc, type: :model do
  context 'factory validation tests' do
    it { expect(create(:dc)).to be_valid }
    it { expect(create(:hyd_dc)).to be_valid }
    it { expect(create(:dc_cdc)).to be_valid }
    it { expect(create(:b2r_bangalore_dc)).to be_valid }
    it { expect(create(:dc_mandi)).to be_valid }
  end

  context 'scope tests' do
    it 'validates scopes' do
      dc1 = create(:dc)
      dc2 = create(:dc)
      dc3 = create(:dc_cdc, is_central: true)
      dc2.dc_type = Dc::Type::CC
      dc2.save!
      dc4 = create(:dc_mandi)

      expect(Dc.non_central_dcs).to include(dc1, dc2)
      expect(Dc.central_dc).to include(dc3)
      expect(Dc.exclude_dc(dc2.id)).to include(dc1, dc3)
      expect(Dc.of_type(Dc::Type::CC)).to include(dc2)
      expect(Dc.of_type(Dc::Type::DC)).to include(dc1)
      expect(Dc.of_name(dc1.name)).to include(dc1)
      expect(Dc.not_deactivated).to include(dc1,dc2,dc3)
      expect(Dc.exclude_mandi).to include(dc1,dc2,dc3)
      expect(Dc.exclude_mandi).not_to include(dc4)
    end
  end

  context 'association test' do
    let!(:location) { create(:location) } 
    let!(:micro_pocket) { create(:micro_pocket) } 
    let!(:zoho_branch) { create(:zoho_branch) } 
    let!(:dc_manager_user) { create(:dc_manager_user)}
    let!(:dc) { create(:dc_mandi, location: location, micro_pocket: micro_pocket, zoho_branch_id: zoho_branch.id, incharge: dc_manager_user, is_central: true) } 
    let!(:active_cost_head) { create(:fruit_ch) }
    let!(:inactive_cost_head) { create(:rent_ch) }
    let!(:active_dc_cost_head) { create(:dc_cost_head, cost_head: active_cost_head, active: true, dc: dc) }
    let!(:inactive_dc_cost_head) { create(:dc_cost_head, cost_head: inactive_cost_head, active: false, dc: dc) }
    let!(:agreement) { create(:agreement, dc_cost_head: active_dc_cost_head)}
    let!(:user) { create(:buyer_approver_user)}
    let!(:user_dc) { create(:user_dc, dc: dc, user: user)}

    it { should belong_to(:location).optional }
    it { should have_many(:shipments) }
    it { should belong_to(:micro_pocket) }
    it { should belong_to(:incharge).optional }
    it { should belong_to(:zoho_branch).optional }
    it { should have_many(:dc_cost_heads) }
    it { should have_many(:active_dc_cost_heads) }
    it { should have_many(:inactive_dc_cost_heads) }
    it { should have_many(:cost_heads).through(:dc_cost_heads) }
    it { should have_many(:active_cost_heads).through(:active_dc_cost_heads).source(:cost_head) }
    it { should have_many(:inactive_cost_heads).through(:inactive_dc_cost_heads).source(:cost_head) }
    it { should have_many(:active_agreements).through(:active_dc_cost_heads).source(:current_agreement) }
    it { should have_many(:source_material_trips).class_name('Trip') }
    it { should have_many(:destination_material_trips).class_name('Trip') }
    it { should have_many(:user_dcs).dependent(:destroy) }
    it { should have_many(:users).through(:user_dcs) }
    it { should have_many(:sale_orders) }
    it { should have_many(:chambers).dependent(:destroy) }
    it { should have_one(:mandi) }
    it { should have_many(:nfi_purchase_orders).class_name('Nfi::PaymentRequestShipment').with_foreign_key('delivery_dc_id') }
    it { should have_many(:dc_state_changes) }

    it "has location" do
      expect(dc.location).to eq(location)
    end

    it "has micro_pocket" do
      expect(dc.micro_pocket).to eq(micro_pocket)
    end

    it "has incharge" do
      expect(dc.incharge).to eq(dc_manager_user)
    end
    
    it "has zoho_branch" do
      expect(dc.zoho_branch).to eq(zoho_branch)
    end

    it "returns shipments" do
      shipment = create(:dc_to_so_shipment, sender: dc)
      expect(dc.shipments).to include(shipment)
    end
    
    it "have dc_cost_heads" do
      expect(dc.dc_cost_heads).to eq([active_dc_cost_head, inactive_dc_cost_head])
    end
    
    it "returns only active dc_cost_heads" do
      expect(dc.active_dc_cost_heads).to include(active_dc_cost_head)
      expect(dc.active_dc_cost_heads).not_to include(inactive_dc_cost_head)
    end

    it "returns only inactive dc_cost_heads" do
      expect(dc.inactive_dc_cost_heads).to include(inactive_dc_cost_head)
      expect(dc.inactive_dc_cost_heads).not_to include(active_dc_cost_head)
    end

    it "returns cost_heads through dc_cost_heads association" do
      expect(dc.cost_heads).to eq([active_cost_head, inactive_cost_head])
    end

    it "returns only active cost_heads through active dc_cost_head" do
      expect(dc.active_cost_heads).to include(active_cost_head)
      expect(dc.active_cost_heads).not_to include(inactive_cost_head)
    end

    it "returns only inactive cost_heads through inactive dc_cost_head" do
      expect(dc.inactive_cost_heads).to include(inactive_cost_head)
      expect(dc.inactive_cost_heads).not_to include(active_cost_head)
    end

    it "returns destination_material_trips" do
      farmer_po = create(:farmer_purchase_order) 
      material_labour_trip = create(:material_labour_trip, source: farmer_po, destination: dc)

      expect(dc.destination_material_trips).to include(material_labour_trip)
    end

    it "returns sale_orders" do
      sale_order = create(:central_sale_order, dc: dc) 
      expect(dc.sale_orders).to include(sale_order)
    end

    it "returns agreement through active dc_cost_head" do
      expect(dc.active_agreements).to include(agreement)
    end

    it "have user_dcs" do
      expect(dc.user_dcs).to include(user_dc)
    end

    it "returns users through user_dcs" do
      expect(dc.users).to include(user)
    end

    it "have chambers" do
      expect(dc.chambers).not_to be_nil
    end

    it "has mandi" do
      expect(dc.mandi).not_to be_nil
    end
  end

  context 'validation test' do
    let!(:dc) { create(:dc) }

    it { should validate_presence_of(:short_code) }
    it { should validate_uniqueness_of(:short_code).case_insensitive }
    it { should validate_inclusion_of(:status).in_array(Dc::Status::ALL) }
    it { should validate_presence_of(:status)}
    it { should_not allow_value('').for(:short_code) }

    it "location_for_non_central validation" do
      dc.is_central = false
      expect(dc.save).to eq(true)
      dc.location_id = nil
      dc.is_central = false
      expect(dc.save).to eq(false)
      expect(dc.errors[:base]).to include("Specify Location")
    end

    it "dc_type::ALL validation" do
      dc.dc_type = Dc::Type::DC
      expect(dc.save).to eq(true)
      dc.dc_type = Dc::Type::ALL
      expect(dc.save).to eq(false)
    end

    it "short_code validation" do
      dc.short_code = create(:dc).short_code
      expect(dc.save).to eq(false)
      dc.short_code = Faker::Alphanumeric.unique.alpha(5)
      expect(dc.save).to eq(true)
    end
  end

  context 'model validation tests' do
    let!(:dc) { create(:dc, is_central: true) }
    let!(:dc_type_mandi) { create(:dc_mandi) }

    it "creates a chamber" do
      expect(dc.chambers).not_to be_nil
      expect(dc_type_mandi.chambers).not_to be_nil
    end

    it "creates a mandi for MANDI type DC" do
      expect(dc.mandi).to be_nil
      expect(dc_type_mandi.mandi).not_to be_nil
    end

    it "before destroy" do
      farmer_po = create(:farmer_purchase_order) 
      material_labour_trip = create(:material_labour_trip, source: farmer_po, destination: dc)

      expect { dc.destroy }.to raise_error(RuntimeError, "Dc can not be deleted as a Material/Labour Trip exists.")
    end

    it "before update prevents deactivation and adds appropriate errors" do
      payment_request = create(:bill_dc_payment_request, dc: dc)
      expect { dc.update(status: Dc::Status::DEACTIVATED ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some incomplete payment requests for this DC")
      expect { dc.update(status: Dc::Status::DORMANT ) }.to change { dc.reload.status }
      expect { dc.update(status: Dc::Status::ACTIVE ) }.to change { dc.reload.status }

      dc_lot = create(:dc_lot, dc: dc, chamber: dc.chambers.first)
      expect { dc.update(status: Dc::Status::DEACTIVATED ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some inventory items in this DC")
      expect { dc.update(status: Dc::Status::DORMANT ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some inventory items in this DC")

      sale_order = create(:central_sale_order, dc: dc) 
      expect { dc.update(status: Dc::Status::DEACTIVATED ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some active sale orders for this DC")
      expect { dc.update(status: Dc::Status::DORMANT ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some active sale orders for this DC")

      shipment = create(:transfer_order_shipment, sender: dc, recipient: create(:material_order))
      expect { dc.update(status: Dc::Status::DEACTIVATED ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some un-dispatched shipments/TOs from this DC")
      expect { dc.update(status: Dc::Status::DORMANT ) }.not_to change { dc.reload.status }
      expect(dc.errors[:status]).to include("There are some un-dispatched shipments/TOs from this DC")

      po = create(:direct_purchase_order)
      test_dc = po.shipments[0].delivery.dc
      po.shipments[0].delivery.update!(vehicle_arrival_time: Time.now, status: Delivery::Status::COMPLETED)
      po.reload
      bpo = build(:bill_po_payment_request, purchase_order: po) 
      expect { test_dc.update(status: Dc::Status::DEACTIVATED ) }.not_to change { test_dc.reload.status }
      expect(test_dc.errors[:status]).to include("There are some Direct POs without a paid PR in this DC")
      expect { test_dc.update(status: Dc::Status::DORMANT ) }.not_to change { test_dc.reload.status }
      expect(test_dc.errors[:status]).to include("There are some Direct POs without a paid PR in this DC")
    end
  end

  context 'other functionality tests' do
    let!(:dc) { create(:dc_mandi) }
    let!(:non_mandi_dc) { create(:hyd_dc, is_central: true) }

    it "checking central function" do
      expect(dc.is_central?).to eq(false)
      expect(non_mandi_dc.is_central?).to eq(true)
    end

    it "checking mandi function" do
      expect(dc.is_mandi?).to eq(true)
      expect(non_mandi_dc.is_mandi?).to eq(false)
    end

    it "checking user_names function" do
      user = create(:buyer_approver_user)
      user_dc = create(:user_dc, dc: dc, user: user)

      expect(dc.user_names).to include(user.name)
    end

    it "checking get_direct_customer_dc function" do
      expect(Dc.get_direct_customer_dc).to eq(non_mandi_dc)
    end

    it "checking get_dc_id_from_name function" do
      expect(Dc.get_dc_id_from_name(dc.name)).to eq(dc.id)
      expect(Dc.get_dc_id_from_name(Faker::Name.first_name)).to eq(nil)
    end

    it "check for type satellite cc" do
      satellite_cc = create(:dc, dc_type: Dc::Type::SATELLITE)
      expect(satellite_cc.is_satellite_dc?).to eq(true)
      expect(dc.is_satellite_dc?).to eq(false)
    end
  end

  context 'state changes' do
    let!(:dc) { create(:dc_mandi) }

    it "checking status to be active" do
      expect(dc.status).to eq(Dc::Status::ACTIVE)
      expect(dc.dc_state_changes.count).to eq(0)
      dc.update!(status: Dc::Status::DORMANT)
      expect(dc.dc_state_changes.count).to eq(1)
      last_dc_state_change = dc.dc_state_changes.last
      expect(last_dc_state_change.to).to eq(Dc::Status::DORMANT)
      expect(last_dc_state_change.from).to eq(Dc::Status::ACTIVE)

      dc.update!(status: Dc::Status::ACTIVE)
      expect(dc.dc_state_changes.count).to eq(2)
      last_dc_state_change = dc.dc_state_changes.last
      expect(last_dc_state_change.to).to eq(Dc::Status::ACTIVE)
      expect(last_dc_state_change.from).to eq(Dc::Status::DORMANT)
    end
  end
end
