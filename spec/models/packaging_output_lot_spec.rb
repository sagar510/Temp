# == Schema Information
#
# Table name: qr_packaging_output_lots
#
# +-----------------------------------------+---------------+------+-----+---------+----------------+
# | Field                                   | Type          | Null | Key | Default | Extra          |
# +-----------------------------------------+---------------+------+-----+---------+----------------+
# | id                                      | bigint        | NO   | PRI | NULL    | auto_increment |
# | packaging_process_id                    | bigint        | NO   | MUL | NULL    |                |
# | sku_id                                  | bigint        | YES  | MUL | NULL    |                |
# | quantity                                | decimal(10,2) | YES  |     | NULL    |                |
# | average_weight                          | decimal(10,2) | YES  |     | NULL    |                |
# | packaging_type_id                       | bigint        | YES  | MUL | NULL    |                |
# | lot_id                                  | bigint        | YES  | MUL | NULL    |                |
# | created_at                              | datetime(6)   | NO   |     | NULL    |                |
# | updated_at                              | datetime(6)   | NO   |     | NULL    |                |
# | lot_type                                | int           | YES  |     | NULL    |                |
# +-----------------------------------------+---------------+------+-----+---------+----------------+

require 'rails_helper'


RSpec.describe Qr::PackagingOutputLot, type: :model do

  it "Factory : creates a valid packaging_output_lot" do
    packaging_output_lot = create :packaging_output_lot
    expect(packaging_output_lot).to be_valid
  end

  describe "ActiveRecord Associations" do
    it { should belong_to(:packaging_process).class_name('Qr::PackagingProcess').with_foreign_key(:packaging_process_id) }
    it { should belong_to(:lot).optional(true) }
    it { should belong_to(:sku) }
    it { should belong_to(:nfi_packaging_item) }
  end

  describe "Validations" do
    it { should validate_presence_of(:packaging_process) }
    it { should validate_presence_of(:sku) }
    it { should validate_presence_of(:nfi_packaging_item) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_inclusion_of(:lot_type).in_array(Qr::PackagingOutputLot::LotType.all) }
  end

  describe "callbacks" do
    describe "before_save callbacks" do
      it "calls :allow_update? before saving" do
        olot = create :packaging_input_lot
        allow(olot).to receive(:allow_update?)
        olot.save
        expect(olot).to have_received(:allow_update?)
      end
    end

    describe "before_destroy callbacks" do
      it "calls :allow_update? before destroying" do
        olot = create :packaging_input_lot
        allow(olot).to receive(:allow_update?)
        olot.destroy
        expect(olot).to have_received(:allow_update?)
      end
    end
  end

  describe "scopes" do

  end

  describe "methods" do
    it "allow_update? (private method)" do
      olot = create :packaging_output_lot
      olot.quantity = 1
      expect { olot.save }.not_to raise_error

      olot.packaging_process.status = Qr::PackagingProcess::Status::COMPLETED
      olot.packaging_process.save
      expect { olot.save }.to raise_error
    end
  end

end