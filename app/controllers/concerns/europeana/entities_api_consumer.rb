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
        wskey: Rails.application.config.x.europeana[:entities].api_key,
        api_url: Rails.application.config.x.europeana[:entities].api_url
      }
    end

    ##
    # Takes a plural human friendly entity type and returns the Entity API's singular equivalent
    #
    # @param human_type [String] one of: people/periods/places/topics
    # return [String] one of: agent/timespan/place/concept
    def entities_api_type(human_type)
      {
        people: 'agent',
        periods: 'timespan',
        places: 'place',
        topics: 'concept'
      }[human_type.to_sym]
    end

    ##
    # Constructs a URL slug for an entity page from the English prefLabel
    #
    # If there is no English prefLabel, the entity page has no URL slug, and
    # the return value will be `nil`.
    #
    # @param entity [HashWithIndifferentAccess] Response from `Europeana::API.entity.fetch`
    # @return [String] URL slug
    def entity_url_slug(entity)
      return nil unless entity.key?(:prefLabel) && entity[:prefLabel].key?(:en)
      pref_label_en = [entity[:prefLabel][:en]].flatten.compact.first
      pref_label_en.nil? ? nil : pref_label_en.to_url
    end
  end
end
