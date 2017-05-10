# Configure Europeana API
if ENV['EUROPEANA_API_URL']
  require 'europeana/api'
  Europeana::API.url = ENV['EUROPEANA_API_URL']
end
Europeana::API.key = Blacklight.connection_config[:europeana_api_key]

# Read some app settings from env vars
if ENV['EUROPEANA_STYLEGUIDE_CDN'] && !ENV['EUROPEANA_STYLEGUIDE_ASSET_HOST']
  ActiveSupport::Deprecation.warn('EUROPEANA_STYLEGUIDE_CDN env var has been renamed to EUROPEANA_STYLEGUIDE_ASSET_HOST')
  ENV['EUROPEANA_STYLEGUIDE_ASSET_HOST'] = ENV['EUROPEANA_STYLEGUIDE_CDN']
end
Rails.application.config.x.europeana_styleguide_asset_host = ENV['EUROPEANA_STYLEGUIDE_ASSET_HOST'] || 'http://styleguide.europeana.eu'

if ENV['EDM_IS_SHOWN_BY_PROXY'] && !ENV['EUROPEANA_MEDIA_PROXY']
  ActiveSupport::Deprecation.warn('EDM_IS_SHOWN_BY_PROXY env var has been renamed to EUROPEANA_MEDIA_PROXY')
  ENV['EUROPEANA_MEDIA_PROXY'] = ENV['EDM_IS_SHOWN_BY_PROXY']
end
Rails.application.config.x.europeana_media_proxy = ENV['EUROPEANA_MEDIA_PROXY'] || 'http://proxy.europeana.eu'

# TODO: As a default, put in the production URL for 1418 once it has been decided on, also update the .env.example file.
Rails.application.config.x.europeana_1914_1918_url = ENV['EUROPEANA_1914_1918_URL'] || 'http://test.1418.eanadev.org'
