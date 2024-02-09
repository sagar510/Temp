# == Schema Information
#
# Table name: qr_packaging_input_lots
#
# +-----------------------------+---------------+------+-----+---------+----------------+
# | Field-Name                  | DataType      | Null?| Key | Default | Extra          |
# +-----------------------------+---------------+------+-----+---------+----------------+
# | id                          | bigint        | NO   | PRI | NULL    | auto_increment |
# | packaging_process_id        | bigint        | NO   | MUL | NULL    |                |
# | lot_id                      | bigint        | YES  | MUL | NULL    |                |
# | quantity                    | decimal(10,2) | YES  |     | NULL    |                |
# | created_at                  | datetime(6)   | NO   |     | NULL    |                |
# | updated_at                  | datetime(6)   | NO   |     | NULL    |                |
# +-----------------------------+---------------+------+-----+---------+----------------+

require 'rails_helper'


RSpec.describe Qr::PackagingInputLot, type: :model do

  it "Factory : creates a valid packaging_input_lot" do
    packaging_input_lot = create :packaging_input_lot
    expect(packaging_input_lot).to be_valid
  end

  describe "ActiveRecord Associations" do
    it { should belong_to(:packaging_process).class_name('Qr::PackagingProcess').with_foreign_key(:packaging_process_id) }
    it { should belong_to(:lot) }
  end

  describe "Validations" do
    it { should validate_presence_of(:packaging_process) }
    it { should validate_presence_of(:lot) }
    it { should validate_presence_of(:lot_id) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }

    it "validates uniqueness of lot_id scoped to packaging_process_id" do
      lot = create :lot
      ilot1 = create :packaging_input_lot
      ilot2 = build(:packaging_input_lot, lot_id: ilot1.lot_id, packaging_process_id: ilot1.packaging_process_id)
      ilot3 = build(:packaging_input_lot, lot_id: lot.id, packaging_process_id: ilot1.packaging_process_id)

      expect(ilot2).to be_invalid
      expect(ilot3).to be_valid
    end
  end

  describe "callbacks" do
    describe "before_save callbacks" do
      it "calls :check_quantity before saving" do
        ilot = create :packaging_input_lot
        allow(ilot).to receive(:check_quantity)
        ilot.save
        expect(ilot).to have_received(:check_quantity)
      end
    
      it "calls :allow_update? before saving" do
        ilot = create :packaging_input_lot
        allow(ilot).to receive(:allow_update?)
        ilot.save
        expect(ilot).to have_received(:allow_update?)
      end
    end

    describe "before_create callbacks" do
      it "calls :block_lot before creating" do
        ilot = create :packaging_input_lot
        expect(ilot.lot.blocked_for_packaging).to eq(true)
      end
    end

    describe "before_destroy callbacks" do
      it "calls :allow_update? before destroying" do
        ilot = create :packaging_input_lot
        allow(ilot).to receive(:allow_update?)
        ilot.destroy
        expect(ilot).to have_received(:allow_update?)
      end

      it "calls :unblock_lot before destroying" do
        ilot = create :packaging_input_lot
        allow(ilot).to receive(:unblock_lot)
        ilot.destroy
        expect(ilot).to have_received(:unblock_lot)
      end
    end
  end

  describe "scopes" do

  end

  describe "methods" do
    it "allow_update? (private method)" do
      ilot = create :packaging_input_lot
      ilot.quantity = 1
      expect { ilot.save }.not_to raise_error

      ilot.packaging_process.status = Qr::PackagingProcess::Status::COMPLETED
      ilot.packaging_process.save
      expect { ilot.save }.to raise_error
    end

    it "check quantity (private method)" do
      expect { create :packaging_input_lot }.not_to raise_error

      expect { create :packaging_input_lot, quantity: 11 }.to raise_error
    end

    it "weight" do
      ilot = create :packaging_input_lot
      if ilot.lot.lot_type == Lot::LotType::NONSTANDARD
        expect = ilot.quantity
      else
        expect = ilot.quantity.to_d * ilot.lot.average_weight.to_d
      end

      actual = ilot.weight
      expect(actual).to eq(expect)
    end

    it "block_lot" do
      lot = create :standard_dc_lot
      expect { create :packaging_input_lot, lot: lot, chamber: lot.chamber }.to change(lot, :blocked_for_packaging).from(false).to(true)
    end

    it "unblock_lot" do
      lot = create :standard_dc_lot
      ilot = create :packaging_input_lot, lot: lot, chamber: lot.chamber
      expect { ilot.unblock_lot }.to change(lot, :blocked_for_packaging).from(true).to(false)
    end
  end

end