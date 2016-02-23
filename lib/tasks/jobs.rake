namespace :jobs do
  namespace :cache do
    desc 'Queue Cache::ColourFacetsJob'
    task colour_facets: :environment do
      Cache::ColourFacetsJob.perform_later
      Collection.published.each do |collection|
        Cache::ColourFacetsJob.perform_later(collection.id)
      end
    end

    desc 'Queue Cache::RecordCountsJob'
    task record_counts: :environment do
      Cache::RecordCountsJob.perform_later
      Collection.published.each do |collection|
        Cache::RecordCountsJob.perform_later(collection.id, types: true)
      end
    end

    desc 'Queue Cache::RecordCounts::RecentAdditionsJob'
    task recent_additions: :environment do
      Cache::RecordCounts::RecentAdditionsJob.perform_later
      Collection.published.each do |collection|
        Cache::RecordCounts::RecentAdditionsJob.perform_later(collection.id)
      end
    end

    desc 'Queue Cache::RecordCounts::ProvidersJob'
    task providers: :environment do
      Cache::RecordCounts::ProvidersJob.perform_later
      Collection.published.each do |collection|
        Cache::RecordCounts::ProvidersJob.perform_later(collection.id)
      end
    end
  end
end
