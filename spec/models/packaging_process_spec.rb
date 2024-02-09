
# == Schema Information
#
# Table name: qr_packaging_processes
#
#-----------------------------------------------------------------------------------------
#| Field-Name                    | DataType      | Null?| Key | Default | Extra          |
#-----------------------------------------------------------------------------------------
#| id                            | bigint        | NO   | PRI | NULL    | auto_increment |
#| regrade_tracker_id            | bigint        | YES  | MUL | NULL    |                |
#| status                        | varchar(255)  | YES  |     | NULL    |                |
#| chamber_id                    | bigint        | YES  | MUL | NULL    |                |
#| product_id                    | bigint        | YES  | MUL | NULL    |                |
#| grade_c_weight                | decimal(10,2) | YES  |     | NULL    |                |
#| moisture_loss                 | decimal(10,2) | YES  |     | NULL    |                |
#| comments                      | text          | YES  |     | NULL    |                |
#| created_at                    | datetime(6)   | NO   |     | NULL    |                |
#| updated_at                    | datetime(6)   | NO   |     | NULL    |                |
#| created_by                    | bigint        | YES  | MUL | NULL    |                |
#| updated_by                    | bigint        | YES  | MUL | NULL    |                |
#-----------------------------------------------------------------------------------------
#


require 'rails_helper'


RSpec.describe Qr::PackagingProcess, type: :model do

  it "Factory : creates a valid packaging_process" do
    packaging_process = create :packaging_process
    expect(packaging_process).to be_valid
  end

  describe "ActiveRecord Associations" do
    it { should belong_to(:chamber).class_name('Chamber').with_foreign_key(:chamber_id) }
    it { should belong_to(:product).class_name('Product').with_foreign_key(:product_id) }
    it { should belong_to(:regrade_tracker).class_name('RegradeTracker').with_foreign_key(:regrade_tracker_id).optional(true) }
    it { should belong_to(:creator).class_name('User').with_foreign_key(:created_by).optional(true) }
    it { should belong_to(:updater).class_name('User').with_foreign_key(:updated_by).optional(true) }

    it { should have_many(:packaging_input_lots).class_name('Qr::PackagingInputLot').with_foreign_key(:packaging_process_id).dependent(:destroy) }
    it { should have_many(:packaging_output_lots).class_name('Qr::PackagingOutputLot').with_foreign_key(:packaging_process_id).dependent(:destroy) }
  end

  describe "Attributes" do
    it "has a default status of 'IN_PROGRESS'" do
      packaging_process_instance = Qr::PackagingProcess.new
      expect(packaging_process_instance.status).to eq(Qr::PackagingProcess::Status::IN_PROGRESS)
    end
  end

  describe "Validations" do
    it { should validate_inclusion_of(:status).in_array(Qr::PackagingProcess::Status.all) }
  
    context "when status is not COMPLETED" do
      let(:packaging_process) { create(:packaging_process, status: Qr::PackagingProcess::Status::IN_PROGRESS, regrade_tracker: nil) }

  
      it "cannot be edited to COMPLETED without a regrade_tracker" do
        packaging_process.status = Qr::PackagingProcess::Status::COMPLETED
        expect(packaging_process).not_to be_valid
      end
  
      it "can be edited to COMPLETED with a regrade_tracker" do
        packaging_process.regrade_tracker = build(:regrade_tracker) # Assuming you have a valid factory for regrade_tracker
        expect(packaging_process).to be_valid
      end
    end
  end
  
  
  

  describe "callbacks" do
    describe "before_save callbacks" do
      it "calls :unblock_all_lots & if: :check_status_changed? before saving" do
        packaging_process = create :packaging_process
        allow(packaging_process).to receive(:check_status_changed?).and_return(true)
        allow(packaging_process).to receive(:unblock_all_lots)
        packaging_process.save
        expect(packaging_process).to have_received(:check_status_changed?)
        expect(packaging_process).to have_received(:unblock_all_lots)
      end
    end

    describe "before_update callbacks" do
      it "calls :allow_update? before saving" do
        packaging_process = create :packaging_process
        allow(packaging_process).to receive(:allow_update?)
        packaging_process.save
        expect(packaging_process).to have_received(:allow_update?)
      end
    end

    describe "before_destroy callbacks" do
      it "calls :allow_destroy? before destroying" do
        packaging_process = create :packaging_process
        allow(packaging_process).to receive(:allow_destroy?)
        packaging_process.destroy
        expect(packaging_process).to have_received(:allow_destroy?)
      end
    end
  end

  describe "scopes" do
    it ".of_regrade_tracker_id(ids)" do
      regrade_tracker = create :regrade_tracker_for_regrade
      process = create :packaging_process, regrade_tracker_id: regrade_tracker.id
      expect(Qr::PackagingProcess.of_regrade_tracker_id(regrade_tracker.id)).to include(process)
      expect(Qr::PackagingProcess.of_regrade_tracker_id(regrade_tracker.id + 1)).not_to include(process)
    end

    it ".of_status(status)" do
      in_progress_process = create :packaging_process
      completed_process = create :packaging_process, status: Qr::PackagingProcess::Status::COMPLETED
      
      expect(Qr::PackagingProcess.of_status(Qr::PackagingProcess::Status::IN_PROGRESS)).to include(in_progress_process)
      expect(Qr::PackagingProcess.of_status(Qr::PackagingProcess::Status::IN_PROGRESS)).not_to include(completed_process)

      expect(Qr::PackagingProcess.of_status(Qr::PackagingProcess::Status::COMPLETED)).to include(completed_process)
      expect(Qr::PackagingProcess.of_status(Qr::PackagingProcess::Status::COMPLETED)).not_to include(in_progress_process)
    end

    it ".of_chamber_id(ids)" do
      process1 = create :packaging_process
      process2 = create :packaging_process
      
      expect(Qr::PackagingProcess.of_chamber_id([process1.chamber_id, process2.chamber_id])).to include(process1, process2)

      expect(Qr::PackagingProcess.of_chamber_id(process1.chamber_id)).to include(process1)
      expect(Qr::PackagingProcess.of_chamber_id(process1.chamber_id)).not_to include(process2)

      expect(Qr::PackagingProcess.of_chamber_id(process2.chamber_id)).to include(process2)
      expect(Qr::PackagingProcess.of_chamber_id(process2.chamber_id)).not_to include(process1)
    end

    it ".of_product_id(ids)" do
      process1 = create :packaging_process
      kinnow = create :kinnow
      process2 = create :packaging_process, product: kinnow
      
      expect(Qr::PackagingProcess.of_product_id([process1.product_id, process2.product_id])).to include(process1, process2)

      expect(Qr::PackagingProcess.of_product_id(process1.product_id)).to include(process1)
      expect(Qr::PackagingProcess.of_product_id(process1.product_id)).not_to include(process2)

      expect(Qr::PackagingProcess.of_product_id(process2.product_id)).to include(process2)
      expect(Qr::PackagingProcess.of_product_id(process2.product_id)).not_to include(process1)
    end

    it ".of_dc_ids(ids)" do
      process1 = create :packaging_process
      process2 = create :packaging_process
      
      expect(Qr::PackagingProcess.of_dc_ids([process1.chamber.dc_id, process2.chamber.dc_id])).to include(process1, process2)

      expect(Qr::PackagingProcess.of_dc_ids(process1.chamber.dc_id)).to include(process1)
      expect(Qr::PackagingProcess.of_dc_ids(process1.chamber.dc_id)).not_to include(process2)

      expect(Qr::PackagingProcess.of_dc_ids(process2.chamber.dc_id)).to include(process2)
      expect(Qr::PackagingProcess.of_dc_ids(process2.chamber.dc_id)).not_to include(process1)
    end

    it ".created_n_days_ago(days)" do
      process1 = create :packaging_process

      #default => 1 day
      expect(Qr::PackagingProcess.created_n_days_ago).not_to include(process1)

      process1.update_column(:created_at, 25.hours.ago)

      expect(Qr::PackagingProcess.created_n_days_ago).to include(process1)
    end
  end

  describe "methods" do
    it "allow_destroy? (private method)" do
      process = create :packaging_process
      expect { process.destroy }.to raise_error

      process.status = Qr::PackagingProcess::Status::CANCELLED
      process.save
      expect { process.destroy }.not_to raise_error
    end

    it "allow_update?" do
      process = create :packaging_process
      expect { process.save }.not_to raise_error

      process.status = Qr::PackagingProcess::Status::CANCELLED
      process.save
      expect { process.save }.to raise_error
    end

    it "returns counts of processes by status" do
      chamber = create :chamber
      in_progress_processes = create_list(:packaging_process, 3, chamber: chamber, status: Qr::PackagingProcess::Status::IN_PROGRESS)
      cancelled_processes = create_list(:packaging_process, 2, chamber: chamber, status: Qr::PackagingProcess::Status::CANCELLED)

      counts = Qr::PackagingProcess.get_status_counts(chamber.dc_id)

      expect(counts[:in_progress]).to eq(3)
      expect(counts[:cancelled]).to eq(2)
      expect(counts[:completed]).to eq(0)
    end
  end

  describe '#build_general_params' do
    it 'should build general parameters' do
      packaging_process = create(:packaging_process)

      general_params = packaging_process.build_general_params

      expect(general_params[:to_primary_chamber]).to be_falsey
      expect(general_params[:chamber_id]).to eq(packaging_process.chamber_id)
      expect(general_params[:moisture_loss]).to eq(packaging_process.moisture_loss)
      expect(general_params[:grade_c_weight]).to eq(packaging_process.grade_c_weight)
      expect(general_params[:dc_id]).to eq(packaging_process.chamber.dc_id)
      expect(general_params[:comments]).to eq(packaging_process.comments)
      expect(general_params[:tracker_type]).to eq(RegradeTracker::TrackerType::PackagingProcess)
    end
  end

  describe '#process_input_lots' do
    it 'should process input lots and return an array of parameters' do
      packaging_process = create(:packaging_process_with_input_lots)
      input_lots = packaging_process.packaging_input_lots
      input_lots_params = packaging_process.send(:process_input_lots)
  
      expect(input_lots_params).to be_an(Array)
      expect(input_lots_params.length).to eq(1)
  
      input_lot_params = input_lots_params.first
      input_lot = input_lots.first
  
      expect(input_lot_params[:id]).to eq(input_lot.lot.id)
      expect(input_lot_params[:chamber_id]).to eq(packaging_process.chamber_id)
      expect(input_lot_params[:dc_id]).to eq(packaging_process.chamber.dc_id)
      expect(input_lot_params[:sku_id]).to eq(input_lot.lot.sku_id)
      expect(input_lot_params[:nfi_packaging_item_id]).to eq(input_lot.lot.nfi_packaging_item_id)
      expect(input_lot_params[:created_date]).to eq(input_lot.lot.created_date)
      expect(input_lot_params[:weight]).to eq(input_lot.quantity * input_lot.lot.average_weight.to_f)
      expect(input_lot_params[:quantity]).to eq(input_lot.quantity)
      expect(input_lot_params[:lot_type]).to eq(input_lot.lot.lot_type)
    end
  end
  
  
  describe '#process_output_lots' do
    it 'should process output lots and return an array of parameters' do
      
      packaging_process = create(:packaging_process_with_output_lots)

      output_lots = packaging_process.packaging_output_lots
      output_lots_params = packaging_process.send(:process_output_lots)
  
      expect(output_lots_params).to be_an(Array)
      expect(output_lots_params.length).to eq(1)
  
      output_lot_params = output_lots_params.first
      output_lot = output_lots.first

      expect(output_lot_params[:dc_id]).to eq(packaging_process.chamber.dc_id)
      expect(output_lot_params[:chamber_id]).to eq(packaging_process.chamber_id)
      expect(output_lot_params[:sku_id]).to eq(output_lot.sku_id)
      expect(output_lot_params[:nfi_packaging_item_id]).to eq(output_lot.nfi_packaging_item_id)
      expect(output_lot_params[:weight]).to eq(output_lot.quantity * output_lot.average_weight.to_f)
      expect(output_lot_params[:quantity]).to eq(output_lot.quantity)
      expect(output_lot_params[:average_weight]).to eq(output_lot.average_weight.to_f)
      expect(output_lot_params[:description]).to eq("PackagingProcess/#{packaging_process.id}")
      expect(output_lot_params[:lot_type]).to eq(Lot::LotType::STANDARD)
    end
  
  end
  
  

end