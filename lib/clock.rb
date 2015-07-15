require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'blog.home') { BlogFeedCacheJob.perform_later('http://blog.europeana.eu/feed/') }
every(1.day, 'blog.art') { BlogFeedCacheJob.perform_later('http://blog.europeana.eu/tag/art/feed/') }
every(1.day, 'blog.music') { BlogFeedCacheJob.perform_later('http://blog.europeana.eu/tag/music/feed/') }
