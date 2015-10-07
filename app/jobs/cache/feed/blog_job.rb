module Cache
  module Feed
    class BlogJob < Cache::FeedJob
      def perform(url)
        super
        @feed.entries.each do |entry|
          img_src = feed_entry_img_src(entry)
          DownloadRemoteMediaObjectJob.perform_later(img_src) unless img_src.nil?
        end
      end

      def feed_entry_img_src(entry)
        return nil unless entry.content.present?
        img_tag = entry.content.match(/<img [^>]*>/i)[0]
        return nil unless img_tag.present?
        img_tag.match(/src="(https?:\/\/[^"]*)"/i)[1]
      end
    end
  end
end
