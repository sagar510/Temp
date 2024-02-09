require 'rails_helper'

RSpec.describe "AppVersions", type: :request do
  
  describe 'GET #latest_app_version' do
    login_admin
    context 'with app_name and environment as parameters' do
      it 'returns the latest app version' do
        app_version = FactoryBot.create(:app_version)
        puts app_version.version
        puts app_version.app_name
        puts app_version.environment
        get '/app_versions/latest_app_version.json', params: {app_name: app_version.app_name, environment: app_version.environment}
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({details:app_version, status: :ok}.to_json)
      end
    end

    context 'parameters app_name or environment not present in request' do
      it 'returns a bad request response' do
        get '/app_versions/latest_app_version.json'
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'params present but no app version found' do
      it 'returns an error response' do
        get '/app_versions/latest_app_version.json', params: { app_name: 'Nonexistent_App', environment: 'Nonexistent_Env' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
