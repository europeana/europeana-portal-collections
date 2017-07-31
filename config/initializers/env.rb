# frozen_string_literal: true

# TODO: Move all uses of env vars out of app/ logic and into this initializer,
#   with app logic instead inspecting `Rails.application.config.x`

# Europeana-centric configuration, e.g. APIs and other sites
Rails.application.config.x.europeana = {}.tap do |europeana|
  europeana[:pro_url] = ENV['EUROPEANA_PRO_URL'] || 'http://pro.europeana.eu'

  europeana[:opensearch_host] = if ENV['EUROPEANA_OPENSEARCH_HOST']
                                  ENV['EUROPEANA_OPENSEARCH_HOST']
                                elsif ENV['HTTP_HOST']
                                  'http://' + ENV['HTTP_HOST']
                                else
                                  ''
                                end

  europeana[:entities] = OpenStruct.new(
    api_key: ENV['EUROPEANA_ENTITIES_API_KEY'] || Europeana::API.key,
    api_url: ENV['EUROPEANA_ENTITIES_API_URL'] || Europeana::API.url
  )
end

# Google-centric configuration
Rails.application.config.x.google = OpenStruct.new(
  analytics_key: ENV['GOOGLE_ANALYTICS_KEY'],
  optimize_container_id: ENV['GOOGLE_OPTIMIZE_CONTAINER_ID'],
  site_verification: ENV['GOOGLE_SITE_VERIFICATION']
)

# Disable certain features that are enabled by default
Rails.application.config.x.disable = OpenStruct.new(
  view_caching: ENV['DISABLE_VIEW_CACHING']
)

# Enable certain features that are disabled by default
Rails.application.config.x.enable = OpenStruct.new(
  blog_posts_theme_filter: ENV['ENABLE_BLOG_POSTS_THEME_FILTER'],
  csrf_without_ssl: ENV['ENABLE_CSRF_WITHOUT_SSL'],
  events_theme_filter: ENV['ENABLE_EVENTS_THEME_FILTER'],
  search_form_autocomplete: ENV['ENABLE_SEARCH_FORM_AUTOCOMPLETE']
)
