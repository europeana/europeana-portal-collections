require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'blog.home', at: ENV['SCHEDULE_BLOG_HOME']) do
  BlogFeedCacheJob.perform_later(FeedCacheJob::URLS[:blog][:all])
end

every(1.day, 'blog.art-history', at: ENV['SCHEDULE_BLOG_ART_HISTORY']) do
  BlogFeedCacheJob.perform_later(FeedCacheJob::URLS[:blog][:art_history])
end

every(1.day, 'blog.music', at: ENV['SCHEDULE_BLOG_MUSIC']) do
  BlogFeedCacheJob.perform_later(FeedCacheJob::URLS[:blog][:music])
end
