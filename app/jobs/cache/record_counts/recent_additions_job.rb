module Cache
  module RecordCounts
    class RecentAdditionsJob < Cache::RecordCountsJob
      def perform
        %w(music art-history).each do |channel|
          cache_key = "record/counts/channels/#{channel}/recent-additions"
          channel_params = Channel.find(channel).config[:params]
          Rails.cache.write(cache_key, recent_additions(channel_params))
        end
      end

      protected

      def recent_additions(params = {})
        recent_additions = []
        time_now = Time.now

        (0..23).each do |months_ago|
          time_from = Time.new(time_now.year, time_now.month) - months_ago.month
          time_to = time_from + 1.month - 1.second

          time_from_param = time_from.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
          time_to_param = time_to.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
          time_range_query = "timestamp_created:[#{time_from_param} TO #{time_to_param}]"

          api_params = params.merge(query: time_range_query, rows: 0, profile: 'minimal facets')
          api_response = repository.search(api_params)

          next if api_response.total == 0

          data_provider_facet = api_response.facet_fields.detect { |f| f['name'] == 'DATA_PROVIDER' }
          next if data_provider_facet.blank?

          data_provider_facet['fields'].each do |field|
            recent_additions << {
              label: field['label'],
              count: field['count'],
              from: time_from,
              query: time_range_query
            }
          end
        end

        recent_additions
      end
    end
  end
end
