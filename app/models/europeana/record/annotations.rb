# frozen_string_literal: true

##
# Annotations support for records
module Europeana
  class Record
    module Annotations
      # TODO: handle pagination if more than 100 items
      def annotations
        @annotations ||= Annotation.find(annotations_search_params)
      end

      def annotations_search_params
        {
          qf: [
            %(generator_name:#{annotations_api_generator_name}),
            %(target_record_id:"#{id}")
          ]
        }
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
