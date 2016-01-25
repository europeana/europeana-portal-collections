module Cache
  module RecordCounts
    ##
    # Gets and caches the number of records for each provider
    #
    # Queues a {DataProvidersJob} for each provider
    class ProvidersJob < ActiveJob::Base
      include ApiQueryingJob

      queue_as :default

      def perform(collection_id = nil)
        cache_key = 'browse/sources/providers'

        builder = search_builder(search_params_logic)
        api_query = builder.rows(0).merge(query: '*:*', profile: 'minimal facets', facet: 'PROVIDER')

        unless collection_id.nil?
          collection = Collection.find(collection_id)
          unless collection.nil?
            api_query.with_overlay_params(collection.api_params_hash)
            cache_key << '/' << collection.key
          end
        end

        response = repository.search(api_query)
        providers = response.aggregations['PROVIDER'].items.map do |item|
          {
            text: item.value,
            count: item.hits
          }
        end
        Rails.cache.write(cache_key, providers)

        providers.each do |provider|
          DataProvidersJob.perform_later(provider[:text], collection_id)
        end
      end
    end
  end
end
