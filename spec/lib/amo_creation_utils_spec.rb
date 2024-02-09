require 'rails_helper'

RSpec.describe "Amo Creation Utils" do
    context "validate amo creation quantity calculation" do
        it "should create quantity by formula" do
            today = Time.now.in_time_zone("Asia/Kolkata")
            tomorrow_start = Time.new(today.year,today.month,today.day+1).in_time_zone("Asia/Kolkata")
            hyd_dc = create :hyd_dc
            dc = create :dc
            dc_cdc = create :dc_cdc
            pomo_sku = create(:sku_pomo)
            dc_product_reach_time = create :dc_product_reach_time, dc: hyd_dc, product: pomo_sku.product
            inventory = create :dc_lot, current_weight: 100, dc: hyd_dc, average_weight: 10
            trip1 = create(:trip)
            del1 = create :delivery, trip: trip1, expected_delivery_time: tomorrow_start, dc: hyd_dc
            pickup1 = create :pickup, trip: trip1
            mo1 = create :material_order, dc: hyd_dc
            shipment1 = create :dc_to_dc_shipment, delivery: del1, pickup: pickup1, sender: dc, recipient: mo1
            lot1 = create :dc_to_dc_shipment_lot, shipment: shipment1, sku: pomo_sku, initial_weight: 100
            
            trip2 = create(:trip)
            del2 = create :delivery, trip: trip2, expected_delivery_time:  Time.new(today.year,today.month,today.day-3).in_time_zone("Asia/Kolkata"), dc: hyd_dc
            pickup2 = create :pickup, trip: trip2
            mo2 = create :material_order, dc: hyd_dc
            shipment2 = create :dc_to_dc_shipment, delivery: del2, pickup: pickup2, sender: dc, recipient: mo2
            lot2 = create :dc_to_dc_shipment_lot, shipment: shipment2, sku: pomo_sku, initial_weight: 100

            trip3 = create(:trip)
            del3 = create :delivery, trip: trip3, expected_delivery_time:  Time.new(today.year,today.month,today.day+4).in_time_zone("Asia/Kolkata"), dc: hyd_dc
            pickup3 = create :pickup, trip: trip3
            mo3 = create :material_order, dc: hyd_dc
            shipment3 = create :dc_to_dc_shipment, delivery: del3, pickup: pickup3, sender: dc, recipient: mo3
            lot3 = create :dc_to_dc_shipment_lot, shipment: shipment3, sku: pomo_sku, initial_weight: 100

            product1 = lot1.product.id

            dc = shipment1.recipient.dc_id

            expect(Lot.dc_in_transit_lots(del1.dc_id, tomorrow_start, tomorrow_start+(60*60*24))).to eq([lot1])
            expect(Lot.includes(:sku, :dc).of_dc(del1.dc_id).inventory.of_products(product1)).to eq([inventory])

            so1 = create :sale_order, expected_delivery_time: Time.new(today.year,today.month,today.day+3).in_time_zone("Asia/Kolkata"), dc: hyd_dc
            soi1 = create :soi_pomo, sale_order: so1, ordered_weight: 200, sku: pomo_sku
            so2 = create :sale_order, expected_delivery_time: Time.new(today.year,today.month,today.day+2).in_time_zone("Asia/Kolkata"), dc: hyd_dc
            soi2 = create :soi_pomo, sale_order: so2, ordered_weight: 100, sku: pomo_sku

            so3 = create :sale_order, expected_delivery_time: Time.new(today.year,today.month,today.day-5).in_time_zone("Asia/Kolkata"), dc: hyd_dc
            soi3 = create :soi_pomo, sale_order: so3, ordered_weight: 10, sku: pomo_sku
            response = AmoCreationUtils.new.create_amos()

            mo = MaterialOrder.find(response["mo_ids"][0])
            expect(mo.material_order_items.size).to eq(1)

            moi = mo.material_order_items.first
            expect(moi.ordered_weight).to eq(soi1.ordered_weight+2*soi3.ordered_weight-(inventory.current_weight+lot1.current_weight-soi2.ordered_weight))
        end
    end
end
