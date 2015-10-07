module Cache
  module RecordCounts
    class RecentAdditionsJob < Cache::RecordCountsJob
      def perform
        time_now = Time.now
        month_now = time_now.month

        %w(music art-history).each do |channel|
          channel_params = Channel.find(channel).config[:params]

          recent_additions = []

          (0..23).each do |months_ago|
            time_from = Time.new(time_now.year, time_now.month) - months_ago.month
            time_to = time_from + 1.month - 1.second

            time_from_param = time_from.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
            time_to_param = time_to.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
            time_range_query = "timestamp_created:[#{time_from_param} TO #{time_to_param}]"

            api_params = channel_params.merge(query: time_range_query, rows: 0, profile: 'minimal facets')
            api_response = repository.search(api_params)

            next if api_response.total == 0

            data_provider_facet = api_response.facet_fields.detect { |f| f['name'] == 'DATA_PROVIDER' }
            next if data_provider_facet.blank?

            data_provider_facet['fields'][0..2].each do |field|
              recent_additions << {
                label: field['label'],
                count: field['count'],
                from: time_from,
                query: time_range_query
              }
            end

            break if recent_additions.size >= 3
          end

          cache_key = "record/counts/channels/#{channel}/recent-additions"
          Rails.cache.write(cache_key, recent_additions)
        end
      end
    end
  end
end
