module Cache
  module RecordCounts
    ##
    # Fetches and counts record counts for each of a provider's data providers
    class DataProvidersJob < ActiveJob::Base
      include ApiQueryingJob

      queue_as :default

      def perform(provider)
        params = { query: '*:*', rows: 0, profile: 'minimal facets', facet: 'DATA_PROVIDER', qf: "PROVIDER:\"#{provider}\"" }
        response = repository.search(params)
        data_provider_facet = response.aggregations['DATA_PROVIDER']
        data_providers = (data_provider_facet.nil? ? [] : data_provider_facet.items).map do |item|
          {
            text: item.value,
            count: item.hits
          }
        end
        Rails.cache.write("browse/sources/providers/#{provider}", data_providers)
      end
    end
  end
end
