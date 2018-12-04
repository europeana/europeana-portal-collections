# frozen_string_literal: true

# TODO: Move all uses of env vars out of app/ logic and into this initializer,
#   with app logic instead inspecting `Rails.application.config.x`

# Europeana-centric configuration, e.g. APIs and other sites
Rails.application.config.x.europeana = {}.tap do |europeana|
  europeana[:pro_url] = ENV['EUROPEANA_PRO_URL'] || 'https://pro.europeana.eu'

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

Rails.application.config.x.gallery = OpenStruct.new(
  annotation_link_resource_host: ENV['GALLERY_ANNOTATION_LINK_RESOURCE_HOST'],
  validation_mail_to: ENV['GALLERY_VALIDATION_MAIL_TO']
)

Rails.application.config.x.exhibitions = OpenStruct.new(
  host: ENV['EXHIBITIONS_HOST'] ||'https://' + (ENV['HTTP_HOST'] || 'www.europeana.eu'),
  annotation_creator_name: ENV['EXHIBITIONS_ANNOTATION_CREATOR_NAME'] || 'Europeana.eu Exhibition'
)

Rails.application.config.x.fulltext = OpenStruct.new(
  dataset_blacklist: ENV['FULLTEXT_DATASET_BLACKLIST'].to_s.split
)

# Google-centric configuration
Rails.application.config.x.google = OpenStruct.new(
  analytics_key: ENV['GOOGLE_ANALYTICS_KEY'],
  analytics_linked_domains: ENV['GOOGLE_ANALYTICS_LINKED_DOMAINS'].to_s.split,
  optimize_container_id: ENV['GOOGLE_OPTIMIZE_CONTAINER_ID'],
  site_verification: ENV['GOOGLE_SITE_VERIFICATION'],
  tag_manager_container_id: ENV['GOOGLE_TAG_MANAGER_CONTAINER_ID']
)

# Grouped configuration settings
#
# Detects env vars with common prefixes and groups them into structured config
# settings.
#
# Prefixes:
# * "DISABLE_": toggles for features enabled by default
# * "ENABLE_": toggles for features disabled by default
# * "SCHEDULE_": scheduling configuration
#
# Examples:
# * +DISABLE_THAT=1+ => +Rails.config.x.disable.that+
# * +ENABLE_THIS=1+ => +Rails.config.x.enable.this+
# * +SCHEDULE_TASK="18:00"+ => +Rails.config.x.schedule.task+
%i(disable enable schedule).each do |group|
  env_prefix = group.to_s.upcase + '_'
  group_env_vars = ENV.select { |k, v| k.start_with?(env_prefix) }
  group_settings = group_env_vars.each_with_object({}) do |(k, v), memo|
                     memo[k.sub(env_prefix, '').downcase.to_sym] = v
                   end
  Rails.application.config.x.send("#{group}=", OpenStruct.new(group_settings))
end

# Environment specific blacklight settings
Rails.application.config.x.blacklight = OpenStruct.new(
  extra_year_facet_collections: ENV['EXTRA_YEAR_FACET_COLLECTIONS'].to_s.split
)
