module FeedHelper
  def feed_entries(url)
    @cached_feed_entries ||= {}
    @cached_feed_entries[url] ||= begin
      feed = Rails.cache.fetch("feed/#{url}")
      feed.present? ? feed.entries : []
    end
  end
end
