module BlogFetcher
  extend ActiveSupport::Concern

  protected

  def fetch_blog_items
    url = 'http://blog.europeana.eu/'
    url << "tag/#{@channel.id}/" if @channel
    url << 'feed/'

    feed = Rails.cache.fetch("feed/#{url}")
    @blog_items = feed.present? ? feed.entries : []
  end
end
