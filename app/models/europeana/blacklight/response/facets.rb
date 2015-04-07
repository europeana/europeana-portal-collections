module Europeana
  module Blacklight
    class Response
      ##
      # Facets for {Europeana::Blacklight::Response}
      #
      # Based on {Blacklight::SolrResponse::Facets} v5.10.2
      module Facets
        require 'ostruct'

        # represents a facet value; which is a field value and its hit count
        class FacetItem < OpenStruct
          def initialize(*args)
            options = args.extract_options!

            # Backwards-compat method signature
            value = args.shift
            hits = args.shift

            options[:value] = value if value
            options[:hits] = hits if hits

            super(options)
          end

          def label
            super || value
          end

          def as_json(props = nil)
            table.as_json(props)
          end
        end

        # represents a facet; which is a field and its values
        class FacetField
          attr_reader :name, :items

          def initialize(name, items, options = {})
            @name, @items = name, items
            @options = options
          end

          def limit
            @options[:limit] || default_limit
          end

          def offset
            @options[:offset] || default_offset
          end

          private

          # @see http://labs.europeana.eu/api/search/#offset-and-limit-of-facets
          def default_limit
            100
          end

          # @see http://labs.europeana.eu/api/search/#offset-and-limit-of-facets
          def default_offset
            0
          end
        end

        def aggregations
          @aggregations ||= {}.merge(facet_field_aggregations).merge(facet_query_aggregations)
        end

        def facet_fields
          @facet_fields ||= self['facets'] || []
        end

        def facet_queries
          @facet_queries ||= self['facet_queries'] || {}
        end

        private

        ##
        # Convert API's facets response into a hash of
        # {Europeana::Blacklight::Response::Facet::FacetField} objects
        def facet_field_aggregations
          facet_fields.each_with_object({}) do |facet, hash|
            facet_field_name = facet['name']
            options = {}
            items = facet['fields'].collect do |value|
              FacetItem.new(value: value['label'], hits: value['count'])
            end

            if params[:"f.#{facet_field_name}.facet.limit"] || params[:"facet.limit"]
              options[:limit] = (params[:"f.#{facet_field_name}.facet.limit"] || params[:"facet.limit"]).to_i
            end

            if params[:"f.#{facet_field_name}.facet.offset"] || params[:'facet.offset']
              options[:offset] = (params[:"f.#{facet_field_name}.facet.offset"] || params[:'facet.offset']).to_i
            end

            hash[facet_field_name] = FacetField.new(facet_field_name, items, options)

            if blacklight_config and !blacklight_config.facet_fields[facet_field_name]
              # alias all the possible blacklight config names..
              blacklight_config.facet_fields.select { |k,v| v.field == facet_field_name }.each do |key, _|
                hash[key] = hash[facet_field_name]
              end
            end
          end
        end

        ##
        # Aggregate API's facet_query response into the virtual facet fields
        # defined in the blacklight configuration
        def facet_query_aggregations
          return {} unless blacklight_config

          blacklight_config.facet_fields.select { |k, v| v.query }.each_with_object({}) do |(field_name, facet_field), hash|
            salient_facet_queries = facet_field.query.map { |k, x| x[:fq] }
            items = []
            facet_queries.select { |k, v| salient_facet_queries.include?(k) }.reject { |value, hits| hits == 0 }.map do |value,hits|
              salient_fields = facet_field.query.select { |key, val| val[:fq] == value }
              key = ((salient_fields.keys if salient_fields.respond_to? :keys) || salient_fields.first).first
              items << FacetItem.new(value: key, hits: hits, label: facet_field.query[key][:label])
            end

            hash[field_name] = FacetField.new(field_name, items)
          end
        end
      end
    end
  end
end
