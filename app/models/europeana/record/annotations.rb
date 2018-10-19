# frozen_string_literal: true

module Europeana
  class Record
    # Annotations support for records
    module Annotations
      # TODO: handle pagination if more than 100 items
      # TODO: allow overriding sort field/order
      def annotations(creator_name: nil, limit: nil)
        @annotations ||= Annotation.find(annotations_search_params(creator_name: creator_name, limit: limit))
      end

      def annotations_search_params(creator_name: '*', limit: 100)
        {
          qf: [
            %(generator_name:#{escape_query_value(annotations_api_generator_name)}),
            %(creator_name:#{escape_query_value(creator_name)}),
            %(target_record_id:"#{id}")
          ],
          sort: 'created',
          sortOrder: 'desc',
          pageSize: limit
        }
      end

      def escape_query_value(value)
        value.gsub(' ', '\ ')
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
