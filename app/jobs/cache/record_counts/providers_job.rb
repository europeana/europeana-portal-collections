module Cache
  module RecordCounts
    ##
    # Gets and caches the number of records for each provider
    #
    # Queues a {DataProvidersJob} for each provider
    class ProvidersJob < ActiveJob::Base
      include ApiQueryingJob

      queue_as :default

      def perform
        params = { query: '*:*', rows: 0, profile: 'minimal facets', facet: 'PROVIDER' }
        response = repository.search(params)
        providers = response.aggregations['PROVIDER'].items.map do |item|
          {
            text: item.value,
            count: item.hits
          }
        end
        Rails.cache.write('browse/sources/providers', providers)

        providers.each do |provider|
          DataProvidersJob.perform_later(provider[:text])
        end
      end
    end
  end
end
