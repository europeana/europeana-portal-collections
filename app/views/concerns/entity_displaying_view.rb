# frozen_string_literal: true
##
# For views needing to display entities
module EntityDisplayingView
  extend ActiveSupport::Concern

  # TODO
  # protected

  # def entity_head_meta
  #   mustache[:entity_head_meta] ||= begin
  #     [
  #         { meta_property: 'fb:appid', content: '185778248173748' },
  #         { meta_name: 'twitter:card', content: 'summary' },
  #         { meta_name: 'twitter:site', content: '@EuropeanaEU' },
  #         { meta_property: 'og:url', content: request.original_url }
  #     ]
  #   end
  # end
end
