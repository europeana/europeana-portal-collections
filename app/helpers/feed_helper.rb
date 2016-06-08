module FeedHelper
  def feed_entries(url)
    feed = cached_feed(url)
    feed.present? ? feed.entries : []
  end

  def cached_feed(url)
    @cached_feeds ||= {}
    @cached_feeds[url] ||= begin
      Rails.cache.fetch("feed/#{url}")
    end
  end

  def feed_entry_img_src(item)
    [:summary, :content].each do |method|
      next unless item.send(method).present?
      img_tag = item.send(method).match(/<img [^>]*>/i)
      next unless img_tag.present?
      url = img_tag[0].match(/src="(https?:\/\/[^"]*)"/i)[1]
      mo = MediaObject.find_by_source_url_hash(MediaObject.hash_source_url(url))
      return mo.file.url(:medium) unless mo.nil?
    end
  end
end
