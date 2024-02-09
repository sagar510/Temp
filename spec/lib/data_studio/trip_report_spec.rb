require 'rails_helper'

RSpec.describe "Data Studio Reports: TripReport" do
  context "validating report returns relevant data" do 
    it "should return results" do
      results = DataStudio::TripReport.new.get_report
      expect(results.size).to eq(1) # Asserting for the header. Todo - expand this test to include data too.
    end
  end
end
