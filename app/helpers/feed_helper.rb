# frozen_string_literal: true

module FeedHelper
  include Europeana::Feeds::FeedHelper

  def tumblr_feed_content(landing_page, options = {})
    page = options[:page] || 1
    per_page = options[:per_page] || 20

    feed = landing_page.feeds.detect(&:tumblr?)

    return nil unless feed

    items = feed_items_for(feed)

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
  # Tries to retrieve a cached feed and formats it for display.
  def feed_items_for(feed)
    feed_entries(feed.url).map do |item|
      {
        url: CGI.unescapeHTML(item.url),
        title: item.title,
        date: I18n.l(item.published, format: :short).gsub(/\s00:00$/, ''),
        published: item.published,
        img: {
          src: feed_entry_thumbnail_url(item),
          alt: item.title
        },
        excerpt: {
          short: strip_tags(CGI.unescapeHTML(item.summary.to_s))
        },
        type: detect_feed_type(feed)
      }
    end
  end

  # entry [Feedjira::Parser::RSSEntry]
  def feed_entry_thumbnail_url(entry)
    FeedEntryImage.new(entry).thumbnail_url
  end

  # Retrieves and combines all of a Page's Feed content so it can be assigned for display.
  def page_feeds_content(page)
    combined_items = page.feeds.map { |feed| feed_items_for(feed) }.flatten
    combined_items.sort_by! { |item| item[:published] }
    combined_items.reverse!

    return nil if combined_items.blank?
    {
      title: false,
      more_items_load: nil,
      more_items_total: combined_items.count,
      items: combined_items
    }
  end

  def detect_feed_type(feed)
    if feed.europeana_blog? || feed.pro_blog?
      'blog'
    elsif feed.tumblr?
      'tumblr'
    else
      'other'
    end
  end
end
