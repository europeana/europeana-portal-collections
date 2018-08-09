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

  def portal_entity_path(entity_url, slug: nil, format: 'html', **options)
    return nil unless europeana_entity_url?(entity_url)
    entity_uri_parts = URI.parse(entity_url).path.split('/')[1..-1]

    options[:type] = entities_human_type(entity_uri_parts[0])
    options[:id] = entity_uri_parts.last
    options[:slug] = slug
    options[:format] = format

    controller.entity_path(options)
  end

  def europeana_entity_url?(entity_url)
    return false unless entity_url.is_a?(String)
    %r(\Ahttps?://data.europeana.eu/[a-z]+/(base/)?\d+\z).match?(entity_url)
  end
end
