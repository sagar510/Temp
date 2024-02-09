require 'rails_helper'

RSpec.describe DcStateChange, type: :model do
  
  context "Associations & Validations" do
    it { should belong_to(:dc) }
    it { should validate_presence_of(:from) }
    it { should validate_presence_of(:to) }
    it { should validate_inclusion_of(:from).in_array(Dc::Status::ALL) }
    it { should validate_inclusion_of(:to).in_array(Dc::Status::ALL) }
  end
end
