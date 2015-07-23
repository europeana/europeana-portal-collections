require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'blog.home', at: ENV['SCHEDULE_BLOG_HOME']) do
  BlogFeedCacheJob.perform_later('http://blog.europeana.eu/feed/')
end

every(1.day, 'blog.art', at: ENV['SCHEDULE_BLOG_ART']) do
  BlogFeedCacheJob.perform_later('http://blog.europeana.eu/tag/art/feed/')
end

every(1.day, 'blog.music', at: ENV['SCHEDULE_BLOG_MUSIC']) do
  BlogFeedCacheJob.perform_later('http://blog.europeana.eu/tag/music/feed/')
end
