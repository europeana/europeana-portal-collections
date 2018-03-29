# frozen_string_literal: true

# TODO: Move all uses of env vars out of app/ logic and into this initializer,
#   with app logic instead inspecting `Rails.application.config.x`

# Europeana-centric configuration, e.g. APIs and other sites
Rails.application.config.x.europeana = {}.tap do |europeana|
  europeana[:contribute_url] = ENV['EUROPEANA_CONTRIBUTE_URL'] || 'http://contribute.europeana.eu'
  europeana[:pro_url] = ENV['EUROPEANA_PRO_URL'] || 'http://pro.europeana.eu'

  europeana[:opensearch_host] = if ENV['EUROPEANA_OPENSEARCH_HOST']
                                  ENV['EUROPEANA_OPENSEARCH_HOST']
                                elsif ENV['HTTP_HOST']
                                  'https://' + ENV['HTTP_HOST']
                                else
                                  ''
                                end

  europeana[:annotations] = OpenStruct.new(
    api_generator_name: ENV['EUROPEANA_ANNOTATIONS_API_GENERATOR_NAME'],
    api_key: ENV['EUROPEANA_ANNOTATIONS_API_KEY'],
    api_url: ENV['EUROPEANA_ANNOTATIONS_API_URL'],
    api_user_token_gallery: ENV['EUROPEANA_ANNOTATIONS_API_USER_TOKEN_GALLERY']
  )

  europeana[:entities] = OpenStruct.new(
    api_key: ENV['EUROPEANA_ENTITIES_API_KEY'],
    api_url: ENV['EUROPEANA_ENTITIES_API_URL']
  )
end

Rails.application.config.x.gallery_validation_mail_to = ENV['GALLERY_VALIDATION_MAIL_TO']

# Google-centric configuration
Rails.application.config.x.google = OpenStruct.new(
  analytics_key: ENV['GOOGLE_ANALYTICS_KEY'],
  analytics_linked_domains: ENV['GOOGLE_ANALYTICS_LINKED_DOMAINS'].to_s.split,
  optimize_container_id: ENV['GOOGLE_OPTIMIZE_CONTAINER_ID'],
  site_verification: ENV['GOOGLE_SITE_VERIFICATION']
)

# Feature toggle to enable/disable certain features
#
# Detects any env vars with name starting "ENABLE_" or "DISABLE_", e.g
# * +ENABLE_THIS=1+ => +Rails.config.x.enable.this+
# * +DISABLE_THAT=1+ => +Rails.config.x.disable.that+
%i(disable enable).each do |switch|
  env_prefix = switch.to_s.upcase + '_'
  feature_env_vars = ENV.select { |k, v| k.start_with?(env_prefix) }
  feature_toggles = feature_env_vars.each_with_object({}) do |(k, v), memo|
                      memo[k.sub(env_prefix, '').downcase.to_sym] = v
                    end
  Rails.application.config.x.send("#{switch}=", OpenStruct.new(feature_toggles))
end

# Environment specific blacklight settings
Rails.application.config.x.blacklight = OpenStruct.new(
  extra_year_facet_collections: ENV['EXTRA_YEAR_FACET_COLLECTIONS'].to_s.split
)
