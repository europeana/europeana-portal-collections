# frozen_string_literal: true
module Cache
  module RecordCounts
    ##
    # Fetches and counts record counts for each of a provider's data providers
    class DataProvidersJob < ApplicationJob
      include ApiQueryingJob

      requests_facet 'DATA_PROVIDER', limit: 1_000

      queue_as :default

      def perform(provider, collection_id = nil)
        @provider = provider
        @collection = Collection.find_by_id(collection_id)
        Rails.cache.write(cache_key, payload)
      end

      protected

      def facet_api_query
        api_query = search_builder.rows(0).merge(query: '*:*', profile: 'minimal facets')
        api_query.with_overlay_params(qf: "PROVIDER:\"#{@provider}\"")
        api_query.with_overlay_params(@collection.api_params_hash) unless @collection.nil?
        api_query
      end

      def cache_key
        [
          'browse/sources/providers',
          (@collection.nil? ? nil : @collection.key),
          @provider
        ].compact.join('/')
      end

      def payload
        data_provider_facet = facet_response.aggregations['DATA_PROVIDER']
        (data_provider_facet.nil? ? [] : data_provider_facet.items).map do |item|
          {
            text: item.value,
            count: item.hits
          }
        end
      end
    end
  end
end
