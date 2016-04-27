module Cache
  module RecordCounts
    class RecentAdditionsJob < ApplicationJob
      include ApiQueryingJob

      queue_as :high_priority

      def perform(collection_id = nil)
        cache_key = 'browse/new_content/providers'
        overlay_params = {}

        unless collection_id.nil?
          collection = Collection.find(collection_id)
          unless collection.nil?
            cache_key = "record/counts/collections/#{collection.key}/recent-additions"
            overlay_params = collection.api_params_hash
          end
        end

        Rails.cache.write(cache_key, recent_additions(overlay_params))
      end

      protected

      def recent_additions(overlay_params = {})
        recent_additions = []
        (0..23).each do |months_ago|
          time = recent_additions_months_ago_time(months_ago)

          api_query = search_builder.rows(0).where(time[:range_query]).merge(profile: 'minimal facets')
          api_query.with_overlay_params(overlay_params)

          api_response = repository.search(api_query)

          next if api_response.total == 0

          data_provider_facet = api_response.facet_fields.detect { |f| f['name'] == 'DATA_PROVIDER' }
          next if data_provider_facet.blank?

          data_provider_facet['fields'].each do |field|
            recent_additions << {
              label: field['label'],
              count: field['count'],
              from: time[:from],
              query: time[:range_query]
            }
          end
        end

        recent_additions
      end

      def recent_additions_time_now
        @recent_additions_time_now ||= Time.zone.now
      end

      def recent_additions_months_ago_time(months_ago)
        {}.tap do |time|
          time[:now] = recent_additions_time_now
          time[:from] = Time.new(time[:now].year, time[:now].month) - months_ago.month
          time[:to] = time[:from] + 1.month - 1.second

          time[:from_param] = time[:from].strftime('%Y-%m-%dT%H:%M:%S.%LZ')
          time[:to_param] = time[:to].strftime('%Y-%m-%dT%H:%M:%S.%LZ')
          time[:range_query] = "timestamp_created:[#{time[:from_param]} TO #{time[:to_param]}]"
        end
      end
    end
  end
end
