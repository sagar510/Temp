require 'rails_helper'
require_relative '../support/devise'

RSpec.describe UsersController, type: :request do


    describe "GET list of users" do
        login_admin 

        it 'fetch all the users of type admin' do
            user1 =  FactoryBot.create(:admin_user)
            user2 =  FactoryBot.create(:admin_user)

            get "/admins.json"
            
            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)
            expect(response_parsed["items"].count).to eq(User.of_role(Role::Name::ADMIN).count)
        end

        it 'fetch all the users of type buyers' do
            user1 =  FactoryBot.create(:buyer_user)
            user2 =  FactoryBot.create(:buyer_user)

            get "/buyers.json"
            
            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)
            expect(response_parsed["items"].count).to eq(User.of_role(Role::Name::BUYER).count)
        end

        it 'fetch all the users of type field_executives' do
            user1 =  FactoryBot.create(:field_executive_user)
            user2 =  FactoryBot.create(:field_executive_user)

            get "/field_executives.json"
            
            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)
            expect(response_parsed["items"].count).to eq(User.of_role(Role::Name::FIELD_EXEC).count)
        end

    end

    describe "GET #current_user_profile" do
        login_admin
    
        it 'fetch current user profile' do
            get "/users/current_user_profile"

            expect(response).to have_http_status(:success)
            response_parsed = JSON.parse(response.body)
            expect(response_parsed['message']).to eq('ok')
            expect(response_parsed['roles']).to eq(["admin"])
            expect(response_parsed['name']).to be_present
            expect(response_parsed['permissions']).to be_present
            expect(response_parsed['email']).to be_present
            expect(response_parsed['id']).to be_present
        end
    end

    describe "PUT #update_zoho_account_id" do 
        login_admin 

        it 'updates zoho account id' do
            user = FactoryBot.create(:admin_user)
            zoho_account_id = 1
            put update_zoho_account_id_user_path(user), params: {
              user: {
                zoho_account_id: zoho_account_id
              }
            }

            user.reload
            expect(response).to have_http_status(:success)
            expect(user.zoho_account_id).to eq(zoho_account_id.to_s)
          end
    end

end