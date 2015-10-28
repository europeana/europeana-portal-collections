module RecordCountsHelper
  def stylised_recent_additions(additions, options = {})
    @stylised_recent_additions ||= begin
      max = options[:max]
      from = options[:from]
      path_meth = within_collection? ? :collection_path : :search_path

      sorted = additions.sort_by { |addition| [-addition[:from].to_i, -addition[:count]] }
      sorted = sorted[0..(max - 1)] if max.present?
      if from == :same
        first_from = sorted.first[:from]
        sorted = sorted.select { |addition| addition[:from] == first_from }
      end

      sorted.map do |addition|
        {
          text: addition[:label],
          number: number_with_delimiter(addition[:count]) + ' ' + t('site.collections.data-types.count'),
          date: addition[:from].strftime('%B %Y'),
          url: send(path_meth, q: addition[:query], f: { 'DATA_PROVIDER' => [addition[:label]] })
        }
      end
    end
  end
end
