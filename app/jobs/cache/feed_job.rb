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
      @feed = begin
        benchmark("[Feedjira] #{url}", level: :info) do
          Feedjira::Feed.fetch_and_parse(url)
        end
      end
      Rails.cache.write("feed/#{url}", @feed)
      if download_media
        @feed.entries.each do |entry|
          img_url = FeedEntryImage.new(entry).media_object_url
          DownloadRemoteMediaObjectJob.perform_later(img_url) unless img_url.nil?
        end
      end
    end
  end
end
