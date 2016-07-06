module Cache
  class RecordCountsJob < ApplicationJob
    include ApiQueryingJob
    include RecordCountsHelper

    queue_as :default

    def perform(collection_id = nil, options = {})
      api_query = search_builder.rows(0).merge(query: '*:*', profile: 'minimal')

      collection = nil
      unless collection_id.nil?
        collection = Collection.find(collection_id)
        unless collection.nil?
          api_query.with_overlay_params(collection.api_params_hash)
        end
      end

      cache_key = record_count_cache_key(collection: collection)
      cache_query_count(api_query, cache_key)

      if options[:types]
        EDM::Type.registry.each do |type|
          type_cache_key = record_count_cache_key(collection: collection, type: type)
          type_api_query = api_query.merge(query: "TYPE:#{type.id}")
          cache_query_count(type_api_query, type_cache_key)
        end
      end
    end
  end
end
