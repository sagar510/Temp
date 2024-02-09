require 'swagger_helper'

RSpec.describe 'user', type: :request do   
  TAG = "User" 
  path "/login" do
    post "Login" do
      tags TAG
      consumes "application/json"
      parameter name: :user_data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
                username: {type: :string},
                password: {type: :string}
            },
            required: ['username', 'password']
          }
        }
      }
      response "200", "success" do
        run_test!
      end
    end
  end
end
