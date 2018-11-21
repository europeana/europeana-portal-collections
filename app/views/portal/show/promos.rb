# frozen_string_literal: true

module Portal
  class Show
    # Promo cards for the new item page
    module Promos
      include EntitiesHelper

      protected

      def js_var_enabled_promos
        promos = [
          { id: 'gallery', url: document_gallery_url(document, format: 'json'), relation: promo_relation('exhibition') },
          { id: 'news', url: document_news_url(document, format: 'json'), relation: promo_relation('news') }
        ] + entity_promos
        promos.push(id: 'generic', url: document_parent_url(document, format: 'json'), relation: promo_relation('dctermsIsPartOf'),) if document_has_europeana_parent?
        promos.to_json
      end

      def entity_promos
        proxy_europeana_entities.map do |uri, fields|
          path_options = portal_entity_path_options(uri, format: 'json')
          relation = fields.map { |field| promo_relation(field) }.join(', ')
          { id: 'entity', url: entity_promo_path(path_options), relation: relation }
        end
      end

      def promo_relation(field)
        t(field, scope: 'site.object.promotions.card-labels', default: field)
      end

      # Scan all proxy fields for data.europeana.eu entity URIs
      #
      # @return [Hash{String => Array<String>}]
      # @example Return value
      #   { "http://data.europeana.eu/concept/base/46" => ["dcType", "dctermsMedium"] }
      def proxy_europeana_entities
        document.proxies.each_with_object({}) do |proxy, memo|
          proxy_field_values(proxy) do |field, values|
            promotable_europeana_entity_uris(values).each do |ec_uri|
              memo[ec_uri] ||= []
              memo[ec_uri].push(field) unless memo[ec_uri].include?(field)
            end
          end
        end
      end

      def proxy_field_values(proxy)
        # Use +#_source+ to bypass localisation of langmap fields
        proxy._source.each_pair do |field, value|
          values = case value
                   when Array
                     value
                   when Hash
                     value.values
                   else
                     [value]
                   end

          yield field, values
        end
      end

      def promotable_europeana_entity_uris(values)
        values.flatten.compact.select { |value| promotable_europeana_entity_uri?(value) }
      end

      # Is an entity URI one which we want to show in a promo card?
      #
      # Criteria:
      # * Must be a Europeana Entity Collection URI
      # * Must be of type concept or agent
      def promotable_europeana_entity_uri?(uri)
        europeana_entity_url?(uri) &&
          (uri.include?('/concept/') || uri.include?('/agent/'))
      end
    end
  end
end
