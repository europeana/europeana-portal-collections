# frozen_string_literal: true
# @todo Move all uses of env vars out of app/ logic and into this initializer,
#   with app logic instead inspecting `Rails.application.config.x`
Rails.application.config.x.europeana ||= {}
Rails.application.config.x.europeana[:pro_url] = ENV['EUROPEANA_PRO_URL'] || 'http://pro.europeana.eu'
