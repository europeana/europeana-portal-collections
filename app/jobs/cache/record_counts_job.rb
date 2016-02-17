module Cache
  class RecordCountsJob < ActiveJob::Base
    include ApiQueryingJob

    queue_as :default

    def perform(collection_id = nil, options = {})
      api_query = search_builder.rows(0).merge(query: '*:*', profile: 'minimal')

      cache_key = 'record/counts'

      if collection_id.nil?
        cache_key << '/all'
      else
        collection = Collection.find(collection_id)
        unless collection.nil?
          cache_key << "/collections/#{collection.key}"
          api_query.with_overlay_params(collection.api_params_hash)
        end
      end

      cache_query_count(api_query, cache_key)

      if options[:types]
        %w(IMAGE SOUND TEXT VIDEO 3D).each do |type|
          type_cache_key = "#{cache_key}/type/#{type.downcase}"
          type_api_query = api_query.merge(query: "TYPE:#{type}")
          cache_query_count(type_api_query, type_cache_key)
        end
      end
    end
  end
end
