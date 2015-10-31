require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

unless ENV['DISABLE_SCHEDULED_JOBS']
  every(1.day, 'cache.feed.blog.home', at: ENV['SCHEDULE_BLOG_HOME']) do
    Cache::Feed::BlogJob.perform_later(Cache::FeedJob::URLS[:blog][:all])
  end

  every(1.day, 'cache.feed.blog.art-history', at: ENV['SCHEDULE_BLOG_ART_HISTORY']) do
    Cache::Feed::BlogJob.perform_later(Cache::FeedJob::URLS[:blog][:art_history])
  end

  every(1.day, 'cache.feed.blog.music', at: ENV['SCHEDULE_BLOG_MUSIC']) do
    Cache::Feed::BlogJob.perform_later(Cache::FeedJob::URLS[:blog][:music])
  end

  every(1.day, 'cache.feed.exhibitions', at: ENV['SCHEDULE_FEED_EXHIBITIONS']) do
    Cache::FeedJob.perform_later(Cache::FeedJob::URLS[:exhibitions][:all])
  end

  every(1.day, 'cache.record-counts', at: ENV['SCHEDULE_RECORD_COUNTS']) do
    Cache::RecordCountsJob.perform_later
    Cache::RecordCounts::RecentAdditionsJob.perform_later
    Cache::RecordCounts::ProvidersJob.perform_later
  end
end
