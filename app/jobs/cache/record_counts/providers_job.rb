# frozen_string_literal: true
module Cache
  module RecordCounts
    ##
    # Gets and caches the number of records for each provider
    #
    # Queues a {DataProvidersJob} for each provider
    class ProvidersJob < ApplicationJob
      include ApiQueryingJob

      requests_facet 'PROVIDER', limit: 1_000

      queue_as :default

      def perform(collection_id = nil)
        @collection = Collection.find_by_id(collection_id)
        payload.tap do |providers|
          Rails.cache.write(cache_key, providers)
          queue_data_provider_jobs(providers)
        end
      end

      protected

      def cache_key
        cache_key = 'browse/sources/providers'
        cache_key += '/' << @collection.key unless @collection.nil?
        cache_key
      end

      def payload
        facet_response.aggregations['PROVIDER'].items.map do |item|
          {
            text: item.value,
            count: item.hits
          }
        end
      end

      def queue_data_provider_jobs(providers)
        providers.each do |provider|
          DataProvidersJob.perform_later(provider[:text], @collection.present? ? @collection.id : nil)
        end
      end
    end
  end
end
