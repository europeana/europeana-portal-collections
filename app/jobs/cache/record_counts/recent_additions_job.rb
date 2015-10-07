module Cache
  module RecordCounts
    class RecentAdditionsJob < ActiveJob::Base
      include ApiQueryingJob

      def perform
        sets.each_pair do |cache_key, params|
          Rails.cache.write(cache_key, recent_additions(params))
        end
      end

      protected

      def sets
        {
          'browse/new_content/providers' => {}
        }.tap do |sets|
          %w(music art-history).each do |channel|
            cache_key = "record/counts/channels/#{channel}/recent-additions"
            channel_params = Channel.find(channel).config[:params]
            sets[cache_key] = channel_params
          end
        end
      end

      def recent_additions(params = {})
        recent_additions = []
        (0..23).each do |months_ago|
          time = recent_additions_months_ago_time(months_ago)

          api_params = params.merge(query: time[:range_query], rows: 0, profile: 'minimal facets')
          api_response = repository.search(api_params)

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
        @recent_additions_time_now ||= Time.now
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
