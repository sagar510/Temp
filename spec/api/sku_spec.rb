require 'swagger_helper'

RSpec.describe 'sku', type: :request do 
    TAG = "Sku"
   
    path "/skus.json" do
        get "Get all the skus" do
            tags TAG
            parameter name: :product_id, in: :query
            consumes "application/json"
            response "200", "success" do
                run_test!
            end
        end
    end

end

