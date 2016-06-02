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
        [:summary, :content].each do |method|
          next unless entry.send(method).present?
          img_tag = entry.send(method).match(/<img [^>]*>/i)[0]
          next unless img_tag.present?
          return img_tag.match(/src="(https?:\/\/[^"]*)"/i)[1]
        end
      end
    end
  end
end
