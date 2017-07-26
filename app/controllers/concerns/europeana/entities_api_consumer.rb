# frozen_string_literal: true

module Europeana
  ##
  # Methods for working with the Europeana Entities API
  module EntitiesApiConsumer
    extend ActiveSupport::Concern

    def entities_api_suggest_params(local_params)
      {
        scope: 'europeana'
      }.merge(entities_api_env_params).merge(local_params)
    end

    def entities_api_fetch_params(type, namespace, identifier)
      {
        type: type,
        namespace: namespace,
        identifier: identifier,
      }.merge(entities_api_env_params)
    end

    def entities_api_env_params
      {
        wskey: Rails.application.config.x.europeana[:entities_api_key],
        api_url: ENV['EUROPEANA_ENTITIES_API_URL'] || Europeana::API.url,
      }
    end
  end
end
