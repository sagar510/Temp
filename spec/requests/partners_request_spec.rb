require 'rails_helper'
require_relative '../support/devise'

RSpec.describe PartnersController, type: :request do
  describe "POST #create_grader" do
    login_admin
    grader_name = Faker::Name.first_name
    grader_phone_number = Faker::PhoneNumber.unique.cell_phone
    
    it 'should create a grader if not present already else update' do
      post "/partners/create_grader.json", params: {
            partner: {
              name: grader_name,
              phone_number: grader_phone_number
            }
          }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['name']).to eq(grader_name)
      expect(response_parsed['phone_number']).to eq(grader_phone_number)
      grader_created_id = response_parsed['id']

      grader_name_1 = Faker::Name.first_name
      post "/partners/create_grader.json", params: {
            partner: {
              name: grader_name_1,
              phone_number: grader_phone_number
            }
          }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['id']).to eq(grader_created_id)
      expect(response_parsed['name']).to eq(grader_name_1)
      expect(response_parsed['phone_number']).to eq(grader_phone_number)
    end
  end

  describe "PUT #update_grader" do
    login_admin
    let(:grader) { create(:grader) }
    grader_name = Faker::Name.first_name
    it 'should uodate a grader if exits else it should create one' do
      put "/partners/#{grader.id}/update_grader.json", params: {
            partner: {
              id: grader.id,
              name: grader_name,
              phone_number: grader.phone_number
            }
          }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['id']).to eq(grader.id)
      expect(response_parsed['name']).to eq(grader_name)
      expect(response_parsed['phone_number']).to eq(grader.phone_number)

      grader_phone_number = Faker::PhoneNumber.unique.cell_phone
      put "/partners/#{grader.id}/update_grader.json", params: {
            partner: {
              id: grader.id,
              name: grader.name,
              phone_number: grader_phone_number
            }
          }
      expect(response).to have_http_status(:success)
      response_parsed = JSON.parse(response.body)
      expect(response_parsed['id']).not_to eq(grader.id)
      expect(response_parsed['name']).to eq(grader.name)
      expect(response_parsed['phone_number']).to eq(grader_phone_number)
    end
  end

end
