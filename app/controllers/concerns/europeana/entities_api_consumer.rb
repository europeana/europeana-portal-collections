# frozen_string_literal: true

module Europeana
  ##
  # Methods for working with the Europeana Entities API
  module EntitiesApiConsumer
    extend ActiveSupport::Concern

    def entities_api_suggest_params(text)
      {
        text: text,
        scope: 'europeana'
      }.reverse_merge(entities_api_env_params)
    end

    def entities_api_fetch_params(type, namespace, identifier)
      {
        type: type,
        namespace: namespace,
        identifier: identifier,
      }.reverse_merge(entities_api_env_params)
    end

    def entities_api_env_params
      {
        wskey: ENV['EUROPEANA_ENTITIES_API_KEY'] || Europeana::API.key,
        api_url: ENV['EUROPEANA_ENTITIES_API_URL'] || Europeana::API.url,
      }
    end
  end
end
