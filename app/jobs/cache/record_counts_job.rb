# frozen_string_literal: true

module Cache
  class RecordCountsJob < ApplicationJob
    include ApiQueryingJob
    include RecordCountsHelper

    queue_as :default

    def perform(collection_id = nil, **options)
      collection = Collection.find_by_id(collection_id)

      perform_for(collection: collection)

      if options[:types]
        EDM::Type.registry.each { |type| perform_for(collection: collection, type: type) }
      end

      collection&.touch_landing_page # Expire landing page cache to show new counts
    end

    protected

    def perform_for(**args)
      cache_query_count(api_query(**args), record_count_cache_key(**args))
    end

    def api_query(collection: nil, type: nil)
      query = search_builder.rows(0).merge(query: '*:*', profile: 'minimal')
      query.with_overlay_params(collection.api_params_hash) unless collection.nil?
      query = query.merge(query: "TYPE:#{type.id}") unless type.nil?
      query
    end
  end
end
