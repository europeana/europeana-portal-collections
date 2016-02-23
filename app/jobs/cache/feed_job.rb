module Cache
  class FeedJob < ApplicationJob
    URLS = {
      blog: {
        all: 'http://blog.europeana.eu/feed/',
        music: 'http://blog.europeana.eu/tag/music/feed/',
        art_history: 'http://blog.europeana.eu/tag/art-history/feed/'
      },
      exhibitions: {
        all: 'http://exhibitions.europeana.eu/rss/exhibitions.xml'
      }
    }

    queue_as :default

    def perform(url)
      @feed = begin
        benchmark("[Feedjira] #{url}", level: :info) do
          Feedjira::Feed.fetch_and_parse(url)
        end
      end
      Rails.cache.write("feed/#{url}", @feed)
    end
  end
end
