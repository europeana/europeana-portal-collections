# frozen_string_literal: true
# @todo Move all uses of env vars out of app/ logic and into this initializer,
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
end

# Google-centric configuration
Rails.application.config.x.google = {}.tap do |google|
  google[:analytics_key] = ENV['GOOGLE_ANALYTICS_KEY']
  google[:site_verification] = ENV['GOOGLE_SITE_VERIFICATION']
end

# Disable certain features that are enabled by default
# [PLACEHOLDER]
# Rails.application.config.x.disable = OpenStruct.new(
#   feature_on_by_default: ENV['DISABLE_FEATURE_ON_BY_DEFAULT']
# )

# Enable certain features that are disabled by default
Rails.application.config.x.enable = OpenStruct.new(
  blog_posts_theme_filter: ENV['ENABLE_BLOG_POSTS_THEME_FILTER'],
  search_form_autocomplete: ENV['ENABLE_SEARCH_FORM_AUTOCOMPLETE']
)
