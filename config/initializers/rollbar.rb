unless Config.rack_env == 'test'
  Rollbar.configure do |config|
    config.enabled = (Config.rack_env == 'production')
    config.environment = Config.console_banner || 'production'
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
    config.use_sucker_punch
    config.disable_monkey_patch = true
    config.root = Config.root
  end

  require 'rollbar/sidekiq'
end
