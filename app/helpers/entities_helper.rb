# frozen_string_literal: true

##
# Entities helpers
module EntitiesHelper
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
  # Inverse of #entities_api_type
  def entities_human_type(api_type)
    {
      agent: 'people',
      timespan: 'periods',
      place: 'places',
      concept: 'topics'
    }[api_type.to_sym]
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

  def portal_entity_path(entity_url, slug: nil, format: 'html')
    begin
      entity_uri = URI.parse(entity_url)
      return nil unless entity_uri.host == 'data.europeana.eu'
    rescue URI::Error
      return nil
    end

    type, namespace, id = entity_uri.path.split('/')[1..-1]
    return nil unless namespace == 'base'

    controller.entity_path(type: entities_human_type(type), id: id, slug: slug, format: format)
  end
end
