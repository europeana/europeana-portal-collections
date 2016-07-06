# frozen_string_literal: true

##
# For working with record counts retrieved from the API
module RecordCountsHelper
  def stylised_recent_additions(additions, options = {})
    @stylised_recent_additions ||= begin
      max = options[:max]
      from = options[:from]
      skip_date = options[:skip_date]
      collection = options[:collection]

      sorted = additions.sort_by { |addition| [-addition[:from].to_i, -addition[:count]] }
      sorted = sorted[0..(max - 1)] if max.present?
      if from == :same
        first_from = sorted.first[:from]
        sorted = sorted.select { |addition| addition[:from] == first_from }
      end

      sorted.map do |addition|
        url_params = { q: addition[:query], f: { 'DATA_PROVIDER' => [addition[:label]] } }
        {
          text: addition[:label],
          number: number_with_delimiter(addition[:count]) + ' ' + t('site.collections.data-types.count'),
          date: skip_date ? false : addition[:from].strftime('%B %Y'),
          url: collection.present? ? collection_path(collection, url_params) : search_path(url_params)
        }
      end
    end
  end

  # @param (see #record_count_cache_key)
  # @return [Fixnum]
  def cached_record_count(**args)
    Rails.cache.fetch(record_count_cache_key(**args)) { 0 }
  end

  # @param type [EDM::Type] EDM type to retrieve record count for
  # @param collection [Collection] collection to retrieve record count for
  def record_count_cache_key(type: nil, collection: nil)
    cache_key = 'record/counts'

    if collection.nil?
      cache_key = cache_key + '/all'
    else
      cache_key = cache_key + "/collections/#{collection.key}"
    end

    if type.present?
      cache_key = cache_key + "/type/#{type.id.downcase}"
    end

    cache_key
  end
end
