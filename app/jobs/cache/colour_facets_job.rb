# frozen_string_literal: true
module Cache
  class ColourFacetsJob < ApplicationJob
    include ApiQueryingJob

    requests_facet 'COLOURPALETTE', limit: 1_000

    queue_as :default

    def perform(collection_id = nil)
      @collection = Collection.find_by_id(collection_id)
      Rails.cache.write(cache_key, payload)
    end

    protected

    def payload
      facet_response.aggregations['COLOURPALETTE'].items
    end

    def cache_key
      [
        'browse/colours/facets',
        (@collection.nil? ? nil : @collection.key)
      ].compact.join('/')
    end
  end
end
