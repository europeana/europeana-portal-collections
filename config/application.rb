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

      # Compress HTTP responses
      config.middleware.use Rack::Deflater

      # Minify HTML
      config.middleware.use HtmlCompressor::Rack, {
        enabled: true,
        remove_multi_spaces: true,
        remove_comments: true,
        remove_intertag_spaces: false,
        remove_quotes: false,
        compress_css: false,
        compress_javascript: false,
        simple_doctype: false,
        remove_script_attributes: false,
        remove_style_attributes: false,
        remove_link_attributes: false,
        remove_form_attributes: false,
        remove_input_attributes: false,
        remove_javascript_protocol: false,
        remove_http_protocol: false,
        remove_https_protocol: false,
        preserve_line_breaks: false,
        simple_boolean_attributes: false,
        compress_js_templates: false
      }

      # Load job classes
      config.autoload_paths += %W(#{config.root}/app/jobs #{config.root}/app/routes)

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
        redis_config = Rails.application.config_for(:redis)
        fail RuntimeError unless redis_config.present?
        [:redis_store, redis_config]
      rescue RuntimeError
        :null_store
      end

      # Load Channels configuration files from config/channels/*.yml files
      config.channels = Dir[Rails.root.join('config', 'channels', '*.yml').to_s].each_with_object({}) do |yml, hash|
        channel = File.basename(yml, '.yml')
        hash[channel] = YAML::load_file(yml)
      end

      # Paperclip file storage config
      config.paperclip_defaults = {
        path: ':class/:id_partition/:attachment/:fingerprint.:style.:extension',
        styles: { small: '200>', medium: '400>', large: '600>' } # max-width
      }
      config.paperclip_defaults.merge! begin
        paperclip_config = Rails.application.config_for(:paperclip)
        fail RuntimeError unless paperclip_config.present?
        paperclip_config.deep_symbolize_keys
      rescue RuntimeError
        {}
      end
    end
  end
end
