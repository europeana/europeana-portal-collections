# frozen_string_literal: true

module Portal
  class Show
    # Promo cards for the new item page
    module Promos
      protected

      def js_var_enabled_promos
        promos = [
          { id: 'gallery', url: document_galleries_url(document, format: 'json') },
          { id: 'blog', url: pro_json_api_posts_for_record_url(document.id) }
        ]

        proxy_europeana_entities.each_pair do |uri, fields|
          promos.push(id: 'entity', url: portal_entity_path(uri, format: 'json', profile: 'promo'), relation: fields.join(', '))
        end
        promos.to_json
      end

      # Scan all proxy fields for data.europeana.eu entity URIs
      #
      # @return [Hash{String => Array<String>}]
      # @example Return value
      #   { "http://data.europeana.eu/concept/base/46" => ["dcType", "dctermsMedium"] }
      def proxy_europeana_entities
        document.proxies.each_with_object({}) do |proxy, memo|
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

            values.flatten.compact.select { |val| promotable_europeana_entity_uri?(val) }.each do |ec_uri|
              memo[ec_uri] ||= []
              memo[ec_uri].push(field) unless memo[ec_uri].include?(field)
            end
          end
        end
      end

      # Is an entity URI one which we want to show in a promo card?
      #
      # Criteria:
      # * Must be a Europeana Entity Collection URI
      # * Must be of type concept or agent
      def promotable_europeana_entity_uri?(uri)
        europeana_entity_url?(uri) &&
          (uri.include?('concept') || uri.include?('agent'))
      end
    end
  end
end
