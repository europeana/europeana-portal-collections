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
end
