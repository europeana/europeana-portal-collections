# frozen_string_literal: true

module Document
  module Entities
    ##
    # Retrieves the document's entities
    #
    # @param type [String,Symbol] name of entity group, e.g. "timespans"
    # @param field [String,Symbol] name of field in the document entities
    #   are to be retrieved for, e.g. "proxies.dctermsTemporal"
    # @return [Array] document's entities
    def document_entities(type, field = nil)
      @entities ||= {}
      @entities[type] ||= {}
      @entities[type][field] ||= entities_for_type(type, field)
    end

    # @param (see #document_entities)
    def entities_for_type(type, field = nil)
      typed_entities = document.fetch(type, [])
      unless field.nil?
        field_values = document.fetch(field, [])
        typed_entities.select! { |entity| field_values.include?(entity[:about]) }
      end
      typed_entities || []
    end
  end
end
