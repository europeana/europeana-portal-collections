class FeedCacheJob < ActiveJob::Base
  include ActiveSupport::Benchmarkable

  queue_as :default

  def perform(url)
    @feed = begin
      benchmark("[Feedjira] #{url}", level: :info) do
        Feedjira::Feed.fetch_and_parse(url)
      end
    end
    Rails.cache.write("feed/#{url}", @feed)
  end
end

