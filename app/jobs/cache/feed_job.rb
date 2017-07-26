# frozen_string_literal: true

module Cache
  class FeedJob < ApplicationJob
    URLS = {
      exhibitions: %i(de en).each_with_object({}) do |locale, hash|
        hash[locale] = (ENV['EXHIBITIONS_HOST'] || 'http://www.europeana.eu') + "/portal/#{locale}/exhibitions/feed.xml"
      end
    }

    queue_as :default

    def perform(url, download_media = false)
      @url = url

      @feed = begin
        benchmark("[Feedjira] #{url}", level: :info) do
          Feedjira::Feed.fetch_and_parse(url)
        end
      end

      cached_feed = Rails.cache.fetch("feed/#{url}")
      if cached_feed.blank? || cached_feed.last_modified != @feed.last_modified
        Rails.cache.write("feed/#{url}", @feed)
        @updated = true
      end

      if download_media
        @feed.entries.each do |entry|
          img_url = FeedEntryImage.new(entry).media_object_url
          DownloadRemoteMediaObjectJob.perform_later(img_url) unless img_url.nil?
        end
      end
    end
  end

  # Global nav uses some feeds, and is cached so needs to be expired when those
  # feeds are updated.
  # Cached pages need to be expired should they be using the updated feed.
  def after_perform
    if @updated
      Cache::Expire::GlobalNavJob.perform_later if NavigableView.feeds_included_in_nav_urls.include?(@url)
      Page.joins(:feeds).where('feed.url' => @url).each do |page|
        Cache::Expire::PageJob.perform_later(page)
      end
    end
  end
end
