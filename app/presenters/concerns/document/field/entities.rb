# frozen_string_literal: true

module Document
  module Field
    ##
    # Methods for presenting entities (agents, concepts, etc)
    module Entities
      ##
      # Retrieves the document's entities
      #
      # @param type [String,Symbol] name of entity group, e.g. "timespans"
      # @param proxy_field [String,Symbol] name of field in proxies entities
      #   are to be retrieved for, e.g. "dctermsTemporal"
      # @return [Array] document's entities
      def entities(type, proxy_field = nil)
        @entities ||= {}
        @entities[type] ||= {}
        @entities[type][proxy_field] ||= entities_for(type, proxy_field)
      end

      # @param (see #entities)
      def entities_for(type, proxy_field = nil)
        entities = document.fetch(type, [])
        unless proxy_field.nil?
          proxy_fields = document.fetch("proxies.#{proxy_field}", [])
          entities.select! { |entity| proxy_fields.include?(entity[:about]) }
        end
        entities || []
      end

      # @param (see #entities)
      # @return [Array]
      def entity_fields(type, proxy_field = nil)
        entities(type, proxy_field).map do |entity|
          [entity_label(entity, type)].flatten
        end
      end

      def entity_label(entity, type)
        entity_pref_label(entity) ||
          entity_foaf_name(entity) ||
          entity_timespan_begin_end(entity, type) ||
          entity[:about]
      end

      def entity_timespan_begin_end(entity, type)
        return nil unless type == 'timespans'

        begin_and_end = [entity.fetch('begin', nil), entity.fetch('end', nil)].compact
        begin_and_end.blank? ? nil : [begin_and_end.join('–')]
      end

      def entity_pref_label(entity)
        entity.fetch('prefLabel', nil)
      end

      def entity_foaf_name(entity)
        entity.fetch('foafName', nil)
      end

      def named_entity_labels(edm, i18n, *args)
        fields = named_entity_fields(edm, i18n, *args)
        return nil if fields.empty?
        {
          title: t("site.object.named-entities.#{i18n}.title"),
          fields: fields
        }
      end

      def named_entity_fields(edm, i18n, *args)
        document.fetch(edm, []).map do |entity|
          properties = [:about, :prefLabel] + (args || [])
          properties.map do |f|
            named_entity_field_label(entity, f, i18n)
          end
        end.flatten.compact
      end

      def named_entity_field_label(entity, field, i18n)
        val = normalise_named_entity(entity[field.to_sym], named_entity_link_field?(field))

        if val.present?
          val = val.first if val.is_a?(Array) && val.size == 1
          multi = (val.is_a?(Hash) || val.is_a?(Array)) && (val.size > 1)

          {
            key: t(named_entity_field_label_i18n_key(field), scope: "site.object.named-entities.#{i18n}"),
            val: multi ? nil : val,
            vals: multi ? val : nil,
            multi: multi,
            foldable_link: named_entity_link_field?(field)
          }
        end
      end

      def named_entity_field_label_i18n_key(field)
        map = { about: 'term', prefLabel: 'label' }
        map.key?(field) ? map[field] : field
      end

      def named_entity_link_field?(field)
        %i(about broader).include?(field)
      end

      def normalise_named_entity(named_entity, foldable_link = false)
        return [] if named_entity.nil?
        return named_entity unless named_entity.is_a?(Hash)
        return named_entity[:def] if named_entity.key?(:def) && named_entity.size == 1

        named_entity.map do |key, val|
          if key && val.nil?
            { val: key, key: nil, foldable_link: foldable_link }
          else
            { key: key, val: val, foldable_link: foldable_link }
          end
        end
      end
    end
  end
end
