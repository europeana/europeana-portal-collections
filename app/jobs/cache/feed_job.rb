# frozen_string_literal: true

module Cache
  class FeedJob < ApplicationJob
    URLS = {
      exhibitions: %i(de en).each_with_object({}) do |locale, hash|
        hash[locale] = (ENV['EXHIBITIONS_HOST'] || 'http://www.europeana.eu') + "/portal/#{locale}/exhibitions/feed.xml"
      end
    }

    queue_as :cache

    def perform(url, download_media = false)
      feed = begin
        benchmark("[Feedjira] #{url}", level: :info) do
          Feedjira::Feed.fetch_and_parse(url)
        end
      end

      feed_cache_key = Feed.find_by_url(url).cache_key
      cached_feed = Rails.cache.fetch(feed_cache_key)
      if cached_feed.blank? || cached_feed.last_modified != feed.last_modified
        Rails.cache.write(feed_cache_key, feed)
        updated = true
      end
      after_perform(feed, url, download_media) if updated
    end

    # Global nav uses some feeds, and is cached so needs to be expired when those
    # feeds are updated.
    # Cached pages need to be expired should they be using the updated feed.
    def after_perform(feed, url, download_media)
      if download_media
        feed.entries.each do |entry|
          img_url = FeedEntryImage.new(entry).media_object_url
          DownloadRemoteMediaObjectJob.perform_later(img_url) unless img_url.nil?
        end
      end
      Cache::Expiry::GlobalNavJob.perform_later if NavigableView.feeds_included_in_nav_urls.include?(url)
      Page.joins(:feeds).where('feeds.url' => url).references(:feeds).each do |page|
        Cache::Expiry::PageJob.perform_later(page.id)
      end
    end
  end
end
