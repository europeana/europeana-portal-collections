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
        tumblr_url: Cache::FeedJob::URLS[:custom][feed.slug.to_sym].sub('/rss', ''),
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
    elsif feed.is_a?(Feed)
      feed_category_key = :custom
      key = feed.slug.to_sym
    end

    url = Cache::FeedJob::URLS[feed_category_key][key]
    feed = cached_feed(url)

    return [] if feed.blank? || feed.entries.blank?

    feed.entries.map do |item|
      {
          url: CGI.unescapeHTML(item.url),
          img: {
              src: feed_entry_thumbnail_url(item),
              alt: item.title
          },
          title: item.title,
          date: I18n.l(item.published, format: :short),
          excerpt: {
              short: ActionController::Base.helpers.strip_tags(CGI.unescapeHTML(item.summary))
          },
          type: detect_feed_type_from_url(url)
      }
    end
  end

  def detect_feed_type_from_url(feed_url)
    if url_in_domain?(feed_url, 'blog.europeana.eu')
      'blog'
    elsif url_in_domain?(feed_url, 'tumblr.com')
      'tumblr'
    else
      'other'
    end
  end

  def url_in_domain?(url, domain)
    !(url =~ %r(://([^/]*.)?#{domain}/)).nil?
  end
end
