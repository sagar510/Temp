require 'rails_helper'

RSpec.describe "Data Studio Reports: TripReport" do
  context "validating report returns relevant data" do 
    it "should return results" do
      lot = create :lot
      puts Lot.count

      PriceCache::Base
      lot.send :publish_lot_created

      po1 = create :farmer_purchase_order, expected_harvest_date: Date.today + 8.day
      po2 = create :farmer_purchase_order, expected_harvest_date: Date.today + 10.day
      shipment1 = create :farm_to_dc_loaded_shipment, sender: po1

      purchase_item1 = create :pi_orange, purchase_order: po1
      purchase_item2 = create :pi_kinnow, purchase_order: po2

      cso1 = create(:central_sale_order)
      soi = create :soi_pomo, sale_order: cso1

      # TODO assert if so-lots have cached the pricing info
    end
  end

  if false # TODO remove after writing clean tests
    def self.tst
      PriceCache::Base
      lot = Lot.last
      lot.send :publish_lot_created
    end

    def self.tst
      PriceCache::Base
      prs = PaymentRequest
              .where('trip_id is not null')
              .of_type(PaymentRequest::PaymentRequestType::BILL)

      pr = prs.last
      pr.send :publish_transportation_cost_updated
    end

    def self.tst
      PriceCache::Base
      pois = PurchaseItem
               .where('parent_id is null')
               .where("created_at < ?", 20.days.ago)

      poi = pois.last
      poi.send :publish_agreed_value_updated
    end

    def self.tst
      PriceCache::Base
      tmis = TripMetaInfo
               .where("created_at < ?", 20.days.ago)

      tmi = tmis.last
      tmi.send :publish_transportation_cost_updated
    end

    def self.tst1
      KafkaUtils::PriceCache::Consumers.new.consume
    end
  end
end
