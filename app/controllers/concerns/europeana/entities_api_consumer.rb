# frozen_string_literal: true

module Europeana
  ##
  # Methods for working with the Europeana Entities API
  module EntitiesApiConsumer
    extend ActiveSupport::Concern

    include EntitiesHelper

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
        wskey: Rails.application.config.x.europeana[:entities].api_key,
      }.tap do |env_params|
        unless Rails.application.config.x.europeana[:entities].api_url.blank?
          env_params[:api_url] = Rails.application.config.x.europeana[:entities].api_url
        end
      end
    end
  end
end
