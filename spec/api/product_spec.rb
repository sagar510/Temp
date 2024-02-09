require 'swagger_helper'

RSpec.describe 'product', type: :request do   
  TAG = "Product" 

  path "/products.json" do
    get "Get all the products" do
      tags TAG
      consumes "application/json"
      response "200", "success" do
        run_test!
      end
    end
  end

  path "/products.json" do
    post "Create Products" do
      tags TAG
      consumes "application/json"
      parameter name: :productDetails, in: :body, schema: {
        type: :object,
        properties: {
            product: {
                type: :object,
                properties: {
                    name: {type: :string},
                    code: {type: :string}
                },
                required: ["name", "code"]
            }
        }
      }
      response "200", "success" do
        run_test!
      end
      
    end
  end
end

