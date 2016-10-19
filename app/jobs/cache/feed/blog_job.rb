module Cache
  module Feed
    class BlogJob < Cache::FeedJob
      def perform(url)
        super
        @feed.entries.each do |entry|
          img_url = FeedEntryImage.new(entry).media_object_url
          DownloadRemoteMediaObjectJob.perform_later(img_url) unless img_url.nil?
        end
      end
    end
  end
end
