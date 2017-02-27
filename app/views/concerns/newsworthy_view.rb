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

  def blog_news_items(collection)
    mustache[:blog_news_items] ||= {}
    mustache[:blog_news_items][collection.key] ||= begin
      key = collection.key.underscore.to_sym
      url = collection.landing_page.feeds.blog.first.url
      news_items(feed_entries(url))
    end
  end
end
