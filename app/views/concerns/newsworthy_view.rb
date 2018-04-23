# frozen_string_literal: true

##
# Views with news from feeds
module NewsworthyView
  protected

  def news_items(items)
    return nil if items.blank?
    items[0..2].map do |item|
      {
        image_root: nil,
        headline: {
          medium: CGI.unescapeHTML(item.title)
        },
        url: CGI.unescapeHTML(item.url),
        img: {
          src: feed_entry_thumbnail_url(item),
          alt: nil
        },
        excerpt: {
          short: CGI.unescapeHTML(item.summary)
        }
      }
    end
  end

  def blog_news_items(feed)
    mustache[:blog_news_items] ||= {}
    mustache[:blog_news_items][feed.slug] ||= begin
      news_items(feed_entries(feed.url))
    end
  end

  def blog_news(landing_page)
    feed = landing_page.feeds.detect(&:europeana_blog?)
    return { items: [], blogurl: false } unless feed
    {
      items: blog_news_items(feed),
      blogurl: feed.url.sub('/feed', '')
    }
  end
end
