# frozen_string_literal: true
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

  def feed_entry_thumbnail_url(entry)
    FeedEntryImage.new(entry).thumbnail_url
  end

  def tumblr_feed_content(landing_page, options = {})
    page = options[:page] || 1
    per_page = options[:per_page] || 20

    puts "landing_page.feeds.tumblr: #{landing_page.feeds.tumblr.inspect}"
    feed = landing_page.feeds.tumblr.first

    return nil unless feed

    items = feed_items_for(feed, options)

    return nil if items.blank?

    paginated_items = Kaminari.paginate_array(items).page(page).per(per_page)
    {
      title: 'Tumblr',
      tumblr_url: feed.url.sub('/rss', ''),
      more_items_load: nil,
      more_items_total: paginated_items.total_count,
      items: items
    }
  end

  ##
  # Tries to retrieve a cached feed and formats it for display
  # feed can be either a Feed, or if it's a standard europeana feed, the collection name as a string.
  def feed_items_for(feed, options = {})
    if feed.is_a?(String)
      feed_category_key = options[:feed_job_category] || :blog
      key = feed.to_sym
      url = Cache::FeedJob::URLS[feed_category_key][key]
      type = feed_category_key.to_s
    elsif feed.is_a?(Feed)
      url = feed.url
      type = detect_feed_type(feed)
    end

    cached_feed = cached_feed(url)

    return [] if cached_feed.blank? || cached_feed.entries.blank?

    cached_feed.entries.map do |item|
      {
        url: CGI.unescapeHTML(item.url),
        img: {
          src: feed_entry_thumbnail_url(item),
          alt: item.title
        },
        title: item.title,
        date: I18n.l(item.published, format: :short),
        excerpt: {
          short: strip_tags(CGI.unescapeHTML(item.summary))
        },
        type: type
      }
    end
  end

  def detect_feed_type(feed)
    if feed.europeana_blog?
      'blog'
    elsif feed.tumblr?
      'tumblr'
    else
      'other'
    end
  end
end
