# Configure Europeana API
if ENV['EUROPEANA_API_URL']
  require 'europeana/api'
  Europeana::API.url = ENV['EUROPEANA_API_URL']
end

unless ENV['EUROPEANA_STYLEGUIDE_ASSET_HOST']
  ENV['EUROPEANA_STYLEGUIDE_ASSET_HOST'] = Rails.application.config.x.europeana_styleguide_cdn
end

Europeana::API.api_key = Blacklight.connection_config[:europeana_api_key]
