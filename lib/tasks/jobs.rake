# frozen_string_literal: true

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
      Feed.all.each do |feed|
        Cache::FeedJob.perform_later(feed.url)
      end
    end
  end

  desc 'Queue FacetLinkGroupGeneratorJob'
  task facet_link_groups: :environment do
    FacetLinkGroup.all.each do |facet_link_group|
      FacetLinkGroupGeneratorJob.perform_later facet_link_group
    end
  end

  task gallery_validation: :environment do
    ActiveSupport::Deprecation.warn('jobs:gallery_validation is deprecated; use jobs:galleries:displayability')
    Rake::Task['jobs:galleries:displayability'].invoke
  end

  namespace :galleries do
    desc 'Queue image displayability verification for all published galleries'
    task displayability: :environment do
      Gallery.published.each(&:enqueue_gallery_displayability_job)
    end

    namespace :annotations do
      desc 'Queue creation of annotations for all published galleries'
      task create: :environment do
        Gallery.published.each(&:store_annotations)
      end

      desc 'Queue deletion of annotations for all published galleries'
      task delete: :environment do
        Gallery.published.each(&:destroy_annotations)
      end
    end
  end
end
