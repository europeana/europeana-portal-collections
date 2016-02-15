module Cache
  class ColourFacetsJob < ActiveJob::Base
    include ApiQueryingJob

    queue_as :default

    def perform(collection_id = nil)
      builder = search_builder
      api_query = builder.rows(0).merge(query: '*:*', profile: 'minimal facets')

      cache_key = 'browse/colours/facets'

      unless collection_id.nil?
        collection = Collection.find(collection_id)
        unless collection.nil?
          api_query.with_overlay_params(collection.api_params_hash)
          cache_key << '/' << collection.key
        end
      end

      response = repository.search(api_query)
      colours = response.aggregations['COLOURPALETTE'].items

      Rails.cache.write(cache_key, colours)
    end
  end
end
