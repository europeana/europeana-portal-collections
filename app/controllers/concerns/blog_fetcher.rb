module BlogFetcher
  extend ActiveSupport::Concern
  include ActiveSupport::Benchmarkable

  protected

  def fetch_blog_items
    url = 'http://blog.europeana.eu/'
    url << "tag/#{@channel.id}/" if @channel
    url << 'feed/'

    feed = Rails.cache.fetch(url) do
      benchmark("[Feedjira] #{url}", level: :info) do
        Feedjira::Feed.fetch_and_parse(url)
      end
    end

    @blog_items = feed.entries
  end
end
