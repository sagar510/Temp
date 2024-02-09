require 'rails_helper'

RSpec.describe "Sale Order item Utils" do
    let(:hyd_dc) { create(:hyd_dc) }
    let(:dc_lot_1) { create(:dc_lot, dc: hyd_dc, created_date: 10.days.ago, quantity: 10, average_weight: 10) }
    let(:dc_lot_2) { create(:dc_lot, dc: hyd_dc, created_date: 10.days.ago, quantity: 10, average_weight: 10) }

    context "validate direct customer return" do
        it "should return to new sale order" do
            user = create :admin_user
            dc = create :dc_cdc
            so = create :central_sale_order, dc: dc
            soi_pomo = create :soi_pomo, ordered_weight: 100, sale_order: so

            params = {"return_dc_id"=> hyd_dc.id, "sale_order_items"=> [{"id": soi_pomo.id, "grn_weight": 90, "return_weight": 10, "return_time": 1648727760000, "has_complaints": false}]}
            soi_params = params["sale_order_items"][0]
            allotment_lot = {"id"=> dc_lot_1.id, "weight"=> 100}
            sale_order_allot_params = [{
                "id" => soi_pomo.id,
                "lots" => [allotment_lot],
                "user_id" => user.id,
                "dc_id" => hyd_dc.id
            }]
            soi_pomo.sale_order.allot_for_sale_order(sale_order_allot_params)
            soi_pomo.reload
            so_item, return_lot = soi_pomo.update_return_info(soi_params)
            shipment = SaleOrderItemUtils.new.handle_returns(params, [return_lot], [soi_params], user.id)
            expect(shipment.lots.size).to eq(1)
            expect(shipment.lots.first.current_weight).to eq(10)

            so2 = create :central_sale_order, dc: dc
            soi_pomo_2 = create :soi_pomo, ordered_weight: 100, sale_order: so2
            
            so3 = create :central_sale_order, dc: dc
            soi_pomo_3 = create :soi_pomo, ordered_weight: 5, sale_order: so3

            so4 = create :central_sale_order, dc: dc
            sku_pomo = create :sku_pomo_grade_c
            soi_pomo_4 = create :soi_pomo, ordered_weight: 10, sale_order: so4, sku: sku_pomo

            params_2 = {"return_sale_order_id"=> so4.id, "sale_order_items"=> [{"id": soi_pomo_2.id, "grn_weight": 90, "return_weight": 10, "return_time": 1648727760000, "has_complaints": false}]}
            
            params_3 = {"return_sale_order_id"=> so3.id, "sale_order_items"=> [{"id": soi_pomo_2.id, "grn_weight": 90, "return_weight": 10, "return_time": 1648727760000, "has_complaints": false}]}
            
            soi_params = params_2["sale_order_items"][0]

            allotment_lot = {"id"=> dc_lot_2.id, "weight"=> 100}
            sale_order_allot_params = [{
                "id" => soi_pomo_2.id,
                "lots" => [allotment_lot],
                "user_id" => user.id,
                "dc_id" => hyd_dc.id
            }]
            soi_pomo_2.sale_order.allot_for_sale_order(sale_order_allot_params)
            soi_pomo_2.reload

            so_item, return_lot = soi_pomo_2.update_return_info(soi_params)

            expect { SaleOrderItemUtils.new.handle_returns(params_2, [return_lot], soi_params, user.id) }.to raise_error
            
            expect { SaleOrderItemUtils.new.handle_returns(params_3, [return_lot], soi_params, user.id) }.to raise_error

            soi_pomo_3.update_columns(ordered_weight: 10)

            SaleOrderItemUtils.new.handle_returns(params_3, [return_lot], soi_params, user.id)
            soi_pomo_3.reload
            expect(soi_pomo_3.sale_order.status).to eq(SaleOrder::Status::FULL_ALLOT)
            expect(soi_pomo_3.sale_order.return_sale).to eq(true)
        end
    end
end
