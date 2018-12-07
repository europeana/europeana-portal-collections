# frozen_string_literal: true

module Europeana
  class Record
    # Annotations support for records
    module Annotations
      # TODO: handle pagination if more than 100 items
      # TODO: allow overriding sort field/order
      def annotations(**options)
        @annotations ||= Annotation.find(annotations_search_params(**options))
      end

      def annotations_search_params(**options)
        {
          qf: annotations_search_params_qf(options[:qf] || {}),
          sort: 'created',
          sortOrder: 'desc',
          pageSize: options[:limit] || 100
        }
      end

      def annotations_search_params_qf(**options)
        [%(target_record_id:"#{id}")].tap do |qf|
          options.each_pair do |field, query|
            qf.push(%(#{field}:#{escape_annotation_query_value(query)}))
          end
        end
      end

      def escape_annotation_query_value(value)
        value.blank? ? '' : value.gsub(/(?<!OR)\s(?!OR)/, '\ ').gsub(':', '\:')
      end

      # @return [String]
      def annotation_target_uri
        "http://data.europeana.eu/item#{id}"
      end
    end
  end
end
