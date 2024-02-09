# == Schema Information
#
# Table name: leads
#
#  id                      :bigint           not null, primary key
#  phone_number            :string(255)      not null
#  source                  :string(255)
#  status                  :string(255)
#  disposition             :string(255)
#  crop                    :string(255)
#  follow_up_date          :date
#  indicative_harvest_date :date
#  has_consultant          :boolean          default(FALSE)
#  consultant_json         :json
#  agent_json              :json
#  other_details_json      :json
#  quality_remarks         :text(65535)
#  cc_exec_id              :bigint
#  fe_exec_id              :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state                   :string(255)      default("Karnataka")
#
require 'rails_helper'

RSpec.describe Lead, type: :model do
  
  context "valid factory test" do 
    it {expect(create(:ka_ac_1)).to be_valid }
    it {expect(create(:ka_cl_1)).to be_valid }
    it {expect(create(:mh_ac_1)).to be_valid }
    it {expect(create(:mh_cl_1)).to be_valid }
  end

  let(:ka_ac_1) { create(:ka_ac_1) }
  let(:ka_cl_1) { create(:ka_cl_1) }
  let(:mh_ac_1) { create(:mh_ac_1) }
  let(:mh_cl_1) { create(:mh_cl_1) }

  describe "ActiveModel validations" do
    # Basic validations
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:disposition) }
    it { should validate_presence_of(:state) }
    it { should validate_inclusion_of(:status).in_array(Lead::Status.all) }
    it { should validate_inclusion_of(:disposition).in_array(Lead::Status.dispositions) }
    it { should validate_inclusion_of(:state).in_array(INDIAN_STATES) }

  end

  context 'ActiveRecord associations' do
    it { should belong_to(:partner).optional }
    it { should belong_to(:cc_exec).optional }
    it { should belong_to(:fe_exec).optional }
  end

end
