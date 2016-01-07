class Cache::ColourFacetsJob < ActiveJob::Base
  include ApiQueryingJob

  queue_as :default

  def perform
    params = { query: '*:*', rows: 0, profile: 'minimal facets' }
    response = repository.search(params)
    colours = response.aggregations['COLOURPALETTE'].items
    cache_key = 'browse/colours/facets'
    Rails.cache.write(cache_key, colours)
  end
end
