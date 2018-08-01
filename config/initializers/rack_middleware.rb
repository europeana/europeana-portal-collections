# frozen_string_literal: true

require 'rack/enforce_http_host'

# Rack middleware configuration
Rails.application.configure do
  config.middleware.use Rack::EnforceHttpHost if ENV.key?('HTTP_HOST')

  # Gzip compress HTTP responses
  config.middleware.use Rack::Deflater if ENV['ENABLE_RACK_HTML_DEFLATER']
end
