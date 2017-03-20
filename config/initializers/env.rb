# frozen_string_literal: true
# @todo Move all uses of env vars out of app/ logic and into this initializer,
#   with app logic instead inspecting `Rails.application.config.x`
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

Rails.application.config.x.google = {}.tap do |google|
  google[:analytics_key] = ENV['GOOGLE_ANALYTICS_KEY']
  google[:site_verification] = ENV['GOOGLE_SITE_VERIFICATION']
end
