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
        super.with_overlay_params(qf: "PROVIDER:\"#{@provider}\"")
      end

      def cache_key
        cache_key = 'browse/sources/providers'
        cache_key += '/' << @collection.key unless @collection.nil?
        cache_key += "/#{@provider}"
        cache_key
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
