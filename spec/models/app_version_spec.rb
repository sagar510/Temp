require 'rails_helper'

RSpec.describe AppVersion, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:app_name) }
    it { should validate_presence_of(:environment) }
    it { should validate_presence_of(:version_code) }
    it { should validate_presence_of(:is_mandatory) }
    it { should validate_presence_of(:apk_link) }  
  end

  describe 'scopes' do
    describe '.of_name' do
      it 'returns app versions with the specified app_name' do
        app_version1 = FactoryBot.create(:app_version, app_name: 'App 1')
        app_version2 = FactoryBot.create(:app_version, app_name: 'App 2')

        result = AppVersion.of_app_name('App 1')

        expect(result).to include(app_version1)
        expect(result).not_to include(app_version2)
      end
    end

    describe '.of_environment' do
      it 'returns app versions with the specified environment' do
        app_version1 = FactoryBot.create(:app_version, environment: 'Env 1')
        app_version2 = FactoryBot.create(:app_version, environment: 'Env 2')

        result = AppVersion.of_environment('Env 1')

        expect(result).to include(app_version1)
        expect(result).not_to include(app_version2)
      end
    end
  end

  describe '.latest_version' do
    it 'returns the latest app version for a given app_name and environment' do
      app_version1 = FactoryBot.create(:app_version, app_name: 'App 1', environment: 'Env 1', created_at: 1.day.ago)
      app_version2 = FactoryBot.create(:app_version, app_name: 'App 1', environment: 'Env 1', created_at: Time.current)
      
      latest_version = AppVersion.latest_version('App 1', 'Env 1')
      
      expect(latest_version).to eq(app_version2)
    end
    
    it 'raises an error when no app version is found' do
      expect { AppVersion.latest_version('Nonexistent App', 'Nonexistent Env') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end