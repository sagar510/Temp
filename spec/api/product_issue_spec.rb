require 'swagger_helper'

RSpec.describe 'product_issue', type: :request do 
    TAG = "Product Issue"
   
    path "/products/{product_id}/product_issues.json" do
        get "Get all the issues for a particular product" do
            tags TAG
            consumes "application/json"
            parameter name: :product_id, in: :path
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/products/{product_id}/product_issues/{product_issue_id}.json" do
        get "Get an issue" do
            tags TAG
            parameter name: :product_id, in: :path
            parameter name: :product_issue_id, in: :path
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/products/{product_id}/product_issues.json" do
        post "Create an issue" do
            tags TAG
            parameter name: :product_id, in: :path
            parameter name: :product_issue_data, in: :body, schema: {
                type: :object,
                properties: {
                    product_issue: {
                        type: :object,
                        properties: {
                            issue: {type: :string}   
                        },
                        required: ['issue', 'password']
                    }
                }
            }
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

    path "/products/{product_id}/product_issues/{product_issue_id}.json" do
        delete "Delete an issue" do
            tags TAG
            parameter name: :product_id, in: :path
            parameter name: :product_issue_id, in: :path
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end
end

