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
          qf: annotations_search_params_qf(**options),
          sort: 'created',
          sortOrder: 'desc',
          pageSize: options[:limit] || 100
        }
      end

      def annotations_search_params_qf(**options)
        [
          %(generator_name:#{escape_annotation_query_value(annotations_api_generator_name)}),
          %(target_record_id:"#{id}")
        ].tap do |qf|
          qf.push(%(creator_name:#{escape_annotation_query_value(options[:creator_name])})) unless options[:creator_name].blank?
          qf.push(%(link_resource_uri:#{escape_annotation_query_value(options[:link_resource_uri])})) unless options[:link_resource_uri].blank?
        end
      end

      def escape_annotation_query_value(value)
        value.blank? ? '' : value.gsub(/(?<!OR)\s(?!OR)/, '\ ').gsub(':', '\:')
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
