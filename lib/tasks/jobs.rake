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

    desc 'Queue Cache::Feed jobs (blogs / exhibitions / Custom)'
    task feeds: :environment do
      Cache::FeedJob::URLS[:exhibitions].values.each do |url|
        Cache::FeedJob.perform_later(url)
      end
      Feed.all.each do |feed|
        Cache::FeedJob.perform_later(feed.url, true)
      end
    end
  end

  desc 'Queue FacetEntryGroupGeneratorJob'
  task facet_endtry_groups: :environment do
    FacetEntryGroup.all.each do |facet_entry_group|
      FacetEntryGroupGeneratorJob.perform_later facet_entry_group
    end
  end
end
