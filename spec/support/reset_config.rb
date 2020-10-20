RSpec.configure do |config|
  config.before { SolidusWebhooks.reset_config! }
end
