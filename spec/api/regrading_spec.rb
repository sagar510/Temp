require 'swagger_helper'

RSpec.describe 'regrading', type: :request do 
    TAG = "Regrading"
   
    path "/regrade_trackers/{regrade_tracker_id}/regradings.json" do
        get "Get all the regradings for a particular regrade tracker" do
            tags TAG
            consumes "application/json"
            parameter name: :regrade_tracker_id, in: :path
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/regrade_trackers/{regrade_tracker_id}/regradings/{regrading_id}.json" do
        get "Get a regrading" do
            tags TAG
            parameter name: :regrade_tracker_id, in: :path
            parameter name: :regrading_id, in: :path
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/regrade_trackers/{regrade_tracker_id}/regradings.json" do
        post "Create a regrading" do
            tags TAG
            parameter name: :regrade_tracker_id, in: :path
            parameter name: :regrading_data, in: :body, schema: {
                type: :object,
                properties: {
                    regrading: {
                        type: :object,
                        properties: {
                            sku_id: {type: :integer},
                            dc_id: {type: :integer},
                            lot_type: {type: :integer},
                            quantity: {type: :integer},
                            weight: {type: :number},
                            partial_weight: {type: :number},
                            average_weight: {type: :number},
                            nfi_packaging_item_id: {type: :number}
                        },
                        required: ['sku_id', 'dc_id', 'lot_type', 'weight']
                    }
                }
            }
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/regrade_trackers/{regrade_tracker_id}/regradings/{regrading_id}.json" do
        delete "Delete an issue" do
            tags TAG
            parameter name: :regrade_tracker_id, in: :path
            parameter name: :regrading_id, in: :path
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end
end

