# frozen_string_literal: true

require File.expand_path('../config/boot', __dir__)
require File.expand_path('../config/environment', __dir__)
require 'clockwork'

include Clockwork

unless ENV['DISABLE_SCHEDULED_JOBS']
  every(1.hour, 'cache.feed.custom') do
    Feed.all.each do |feed|
      Cache::FeedJob.perform_later(feed.url)
    end
  end

  every(1.day, 'cache.record-counts', at: ENV['SCHEDULE_RECORD_COUNTS']) do
    Cache::ColourFacetsJob.perform_later
    Cache::RecordCountsJob.perform_later
    Cache::RecordCounts::RecentAdditionsJob.perform_later
    Cache::RecordCounts::ProvidersJob.perform_later

    Collection.published.each do |collection|
      Cache::ColourFacetsJob.perform_later(collection.id)
      Cache::RecordCountsJob.perform_later(collection.id, types: true)
      Cache::RecordCounts::RecentAdditionsJob.perform_later(collection.id)
      Cache::RecordCounts::ProvidersJob.perform_later(collection.id)
    end
  end

  every(1.day, 'facet-link-groups', at: ENV['SCHEDULE_FACET_ENTRY_GROUPS_GENERATOR']) do
    FacetLinkGroup.all.each do |facet_link_group|
      FacetLinkGroupGeneratorJob.perform_later facet_link_group
    end
  end

  ENV['SCHEDULE_GALLERY_VALIDATION']&.split(' ')&.each do |gallery_validation_time|
    every(1.day, 'gallery-validation', at: gallery_validation_time) do
      Gallery.published.each do |gallery|
        GalleryDisplayabilityJob.perform_later(gallery.id)
      end
    end
  end

  every(1.day, 'db.sweeper', at: ENV['SCHEDULE_DB_SWEEPER']) do
    DeleteOldSearchesJob.perform_later
  end
end
