require 'faker'
require 'factory_bot_rails'

module UserHelpers

  def create_user
    FactoryBot.create(:user)
  end

  def build_user
    FactoryBot.build(:user)
  end

end