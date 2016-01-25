module Cache
  module RecordCounts
    ##
    # Fetches and counts record counts for each of a provider's data providers
    class DataProvidersJob < ActiveJob::Base
      include ApiQueryingJob

      queue_as :default

      def perform(provider, collection_id = nil)
        builder = search_builder(search_params_logic)
        api_query = builder.rows(0).merge(query: '*:*', profile: 'minimal facets', facet: 'DATA_PROVIDER', qf: "PROVIDER:\"#{provider}\"")

        cache_key = 'browse/sources/providers'

        unless collection_id.nil?
          collection = Collection.find(collection_id)
          unless collection.nil?
            api_query.with_overlay_params(collection.api_params_hash)
            cache_key << '/' << collection.key
          end
        end

        cache_key << "/#{provider}"

        response = repository.search(api_query)
        data_provider_facet = response.aggregations['DATA_PROVIDER']
        data_providers = (data_provider_facet.nil? ? [] : data_provider_facet.items).map do |item|
          {
            text: item.value,
            count: item.hits
          }
        end
        Rails.cache.write(cache_key, data_providers)
      end
    end
  end
end
