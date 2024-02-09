require 'swagger_helper'

RSpec.describe 'regrade_tracker_issue', type: :request do 
    TAG = "Regrade Tracker"
   
    path "/regrade_trackers.json" do
        get "Get all the regrade trackers" do
            tags TAG
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/regrade_trackers/{regrade_tracker_id}.json" do
        get "Get a regrade tracker" do
            tags TAG
            parameter name: :regrade_tracker_id, in: :path
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/regrade_trackers.json" do
        post "Create a regrade tracker" do
            tags TAG
            parameter name: :regrade_tracker_data, in: :body, schema: {
                type: :object,
                properties: {
                    regrade_tracker: {
                        type: :object,
                        properties: {
                            user_id: {type: :integer},
                            dc_id: {type: :integer},
                            product_id: {type: :integer},
                            comments: {type: :string},
                            moisture_loss: {type: :number},
                            grade_c_weight: {type: :number},
                            start_time: {type: :integer},
                            end_time: {type: :integer},   
                        },
                        required: ['user_id', 'dc_id', 'product_id']
                    }
                }
            }
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/regrade_trackers/{regrade_tracker_id}.json" do
        delete "Delete a regrade tracker" do
            tags TAG
            parameter name: :regrade_tracker_id, in: :path
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end
end

