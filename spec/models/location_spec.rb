# spec/models/location_spec.rb
require 'rails_helper'

RSpec.describe Location, type: :model do
  describe ".nearest_location" do
    it "returns the nearest location ordered by distance" do

      location1 = Location.create(state: "Karnataka", district: "Mysore", lat: 12.971598, lng: 77.594562)
      location2 = Location.create(state: "Karnataka", district: "Banglore", lat: 13.082680, lng: 80.270721)

      reference_latitude = 12.971598
      reference_longitude = 77.594562

      nearest_location = Location.nearest_location(reference_latitude, reference_longitude).first

      expect(nearest_location).to eq(location1)
      
    end
  end
end