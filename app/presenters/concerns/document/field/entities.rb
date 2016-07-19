# frozen_string_literal: true
module Document
  module Field
    ##
    # Methods for presenting entities (agents, concepts, etc)
    module Entities
      def entities(entity_name, proxy_field = nil)
        @entities ||= {}
        @entities[entity_name] ||= {}
        @entities[entity_name][proxy_field] ||= begin
          entities = document.fetch(entity_name, [])
          unless proxy_field.nil?
            proxy_fields = document.fetch("proxies.#{proxy_field}", [])
            entities.select! { |entity| proxy_fields.include?(entity[:about]) }
          end
          entities || []
        end
      end

      def entity_fields(entity_name, proxy_field = nil)
        entities(entity_name, proxy_field).map { |entity| entity_label(entity) }
      end

      def entity_label(entity)
        [entity.fetch('prefLabel', entity.fetch('foafName', entity[:about]))].flatten
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
        [:about, :broader].include?(field)
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
