module ControllerMacros
  def login_fe
    before(:each) do
      user = FactoryBot.create(:field_executive_user)
      sign_in user
    end
  end

  def login_cce
    before(:each) do
      user = FactoryBot.create(:farmer_engagement_executive_user)
      sign_in user
    end
  end

  def login_admin
    before(:each) do
      user = FactoryBot.create(:admin_user)
      sign_in user
    end
  end

  def set_devise_mapping
    request.env['devise.mapping'] = Devise.mappings[:user]
  end
end