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

          def sort
            @options[:sort] || default_sort
          end

          def offset
            @options[:offset] || default_offset
          end

          private

          def default_limit
            100
          end

          def default_sort
            nil
          end

          def default_offset
            0
          end
        end

        def facets
          @facets ||= begin
            facet_fields.map do |facet_field|
              facet_field_name = facet_field['name']
              items = facet_field['fields'].map do |item|
                FacetItem.new(value: item['label'], hits: item['count'])
              end
              options = {}
              options[:sort] = (params[:"f.#{facet_field_name}.facet.sort"] || params[:'facet.sort'])
              if params[:"f.#{facet_field_name}.facet.limit"] || params[:"facet.limit"]
                options[:limit] = (params[:"f.#{facet_field_name}.facet.limit"] || params[:"facet.limit"]).to_i
              end
              if params[:"f.#{facet_field_name}.facet.offset"] || params[:'facet.offset']
                options[:offset] = (params[:"f.#{facet_field_name}.facet.offset"] || params[:'facet.offset']).to_i
              end
              FacetField.new(facet_field_name, items, options)
            end
          end
        end

        def facet_by_field_name(name)
          @facets_by_field_name ||= {}
          @facets_by_field_name[name] ||= (
            facets.detect { |facet| facet.name.to_s == name.to_s }
          )
        end

        def facet_fields
          @facet_fields ||= self['facets'] || []
        end

        def facet_queries
          @facet_queries ||= self['facet_queries'] || {}
        end

        def facet_pivot
          @facet_pivot ||= {}
        end
      end
    end
  end
end
