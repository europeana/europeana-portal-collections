# frozen_string_literal: true

module Document
  module Field
    ##
    # Methods for presenting entities (agents, concepts, etc)
    # TODO: move to an EntitiePresenter class?
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
        @entities[type][field] ||= document_entities_for_type(type, field)
      end

      # @param (see #document_entities)
      def document_entities_for_type(type, field = nil)
        document_entities = document.fetch(type, [])
        unless field.nil?
          doc_field_values = document.fetch(field, [])
          document_entities.select! { |entity| doc_field_values.include?(entity[:about]) }
        end
        document_entities || []
      end

      def entity_label(entity)
        entity_pref_label(entity) ||
          entity_foaf_name(entity) ||
          entity_timespan_begin_end(entity) ||
          entity_alt_label(entity) ||
          entity[:about]
      end

      def entity_potential_labels(entity)
        [
          entity_pref_label(entity),
          entity_foaf_name(entity),
          entity_timespan_begin_end(entity),
          entity_alt_label(entity),
          entity[:about]
        ].flatten
      end

      def entity_alt_label(entity)
        entity.fetch('altLabel', nil)
      end

      def entity_pref_label(entity)
        entity.fetch('prefLabel', nil)
      end

      def entity_foaf_name(entity)
        entity.fetch('foafName', nil)
      end

      def entity_timespan_begin_end(entity)
        begin_and_end = [entity.fetch('begin', nil), entity.fetch('end', nil)].compact
        begin_and_end.blank? ? nil : [begin_and_end.join('–')]
      end
    end
  end
end
