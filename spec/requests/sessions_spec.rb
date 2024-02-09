require 'rails_helper'

describe "SessionsController", type: :request do
  let (:user) { create(:admin_user) }
  # let (:login_url) { '/login' }
  # let (:logout_url) { '/logout' }

  context 'When logging in' do
    it 'returns a token' do
      login_with_api(user)
      expect(response.headers['Authorization']).to be_present
    end

    # it 'returns 200' do
    #   expect(response.status).to eq(200)
    # end
  end

  # context 'When password is missing' do
  #   before do
  #     post login_url, params: {
  #       user: {
  #         email: user.email,
  #         password: nil
  #       }
  #     }
  #   end

  #   it 'returns 401' do
  #     expect(response.status).to eq(401)
  #   end

  # end

  # context 'When logging out' do
  #   it 'returns 204' do
  #     delete logout_url

  #     expect(response).to have_http_status(204)
  #   end
  # end

end