FactoryBot.define do
  factory :app_version do
    app_name { 'Test App' }
    environment { 'Test Env' }
    version_code { '1.0' }
    is_mandatory { true }
    apk_link { 'https://example.com' }
  end
end
