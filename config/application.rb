require File.expand_path('../boot', __FILE__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Europeana
  module Portal
    class Application < Rails::Application
      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Load job, routing and view concern classes
      config.autoload_paths += %W(
        #{config.root}/app/jobs #{config.root}/app/jobs/concerns
        #{config.root}/app/routes #{config.root}/app/presenters
      )

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      # config.time_zone = 'Central Time (US & Canada)'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      # config.i18n.default_locale = :de
      config.i18n.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml}"]

      # Do not swallow errors in after_commit/after_rollback callbacks.
      config.active_record.raise_in_transactional_callbacks = true

      # Use Delayed::Job as the job queue adapter
      config.active_job.queue_adapter = :delayed_job

      # Read relative URL root from env
      config.relative_url_root = ENV['RAILS_RELATIVE_URL_ROOT']

      # Load Redis config from config/redis.yml, if it exists
      config.cache_store = begin
        redis_config = Rails.application.config_for(:redis).symbolize_keys
        fail RuntimeError unless redis_config.present?

        uri = URI::Generic.build(scheme: 'redis')
        uri.user = redis_config[:name]
        uri.password = redis_config[:password]
        uri.host = redis_config[:host]
        uri.port = redis_config[:port]
        uri.path = '/' + [redis_config[:db], redis_config[:namespace]].join('/')

        [:redis_store, uri.to_s]
      rescue RuntimeError
        :null_store
      end

      # Read settings from env vars
      config.x.edm_is_shown_by_proxy = ENV['EDM_IS_SHOWN_BY_PROXY']
      config.x.europeana_styleguide_cdn = ENV['EUROPEANA_STYLEGUIDE_CDN']
      config.x.js_entrypoint = ENV['JS_ENTRYPOINT']
      config.x.js_version = ENV['JS_VERSION']
    end
  end
end
