# frozen_string_literal: true

module Europeana
  class Record
    # Annotations support for records
    module Annotations
      # TODO: handle pagination if more than 100 items
      # TODO: allow overriding sort field/order
      def annotations(**options)
        options.slice!(:creator_name, :link_resource_uri, :limit)
        @annotations ||= Annotation.find(annotations_search_params(**options))
      end

      def annotations_search_params(**options)
        {
          qf: [
            %(generator_name:#{escape_annotation_query_value(annotations_api_generator_name)}),
            %(creator_name:#{escape_annotation_query_value(options[:creator_name] || '*')}),
            %(link_resource_uri:#{escape_annotation_query_value(options[:link_resource_uri] || '*')}),
            %(target_record_id:"#{id}")
          ],
          sort: 'created',
          sortOrder: 'desc',
          pageSize: options[:limit] || 100
        }
      end

      def escape_annotation_query_value(value)
        value.blank? ? '' : value.gsub(%r((?<!OR)\s(?!OR)), '\ ').gsub(':', '\:')
      end

      def annotations_api_generator_name
        Rails.application.config.x.europeana[:annotations].api_generator_name || 'Europeana.eu*'
      end

      # @return [String]
      def annotation_target_uri
        "http://data.europeana.eu/item#{id}"
      end
    end
  end
end
