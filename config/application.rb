require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Europeana
  module Portal
    class Application < Rails::Application
      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      # config.time_zone = 'Central Time (US & Canada)'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      # config.i18n.default_locale = :de
      config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]

      # Do not swallow errors in after_commit/after_rollback callbacks.
      config.active_record.raise_in_transactional_callbacks = true

      # Load Redis config from config/redis.yml, if it exists
      begin
        config.cache_store = :redis_store, Rails.application.config_for(:redis)
      rescue
        config.cache_store = :null_store
      end

      # Load Channels configuration files from config/channels/*.yml files
      config.channels = Dir[Rails.root.join('config', 'channels', '*.yml').to_s].each_with_object({}) do |yml, hash|
        channel = File.basename(yml, '.yml').to_sym
        hash[channel] = YAML::load_file(yml)
      end
    end
  end
end
