# frozen_string_literal: true
module Cache
  class FeedJob < ApplicationJob
    def self.custom_feeds
      {
        custom: ::Feed.all.each_with_object({}) do |feed, hash|
          hash[feed.slug.to_sym] = feed.url
        end
      }
    end

    URLS = {
      blog: {
        all: 'http://blog.europeana.eu/feed/',
        art: 'http://blog.europeana.eu/tag/art/feed/',
        fashion: 'http://blog.europeana.eu/tag/fashion/feed/',
        music: 'http://blog.europeana.eu/tag/music/feed/'
      },
      exhibitions: %i(de en).each_with_object({}) do |locale, hash|
        hash[locale] = (ENV['EXHIBITIONS_HOST'] || 'http://www.europeana.eu') + "/portal/#{locale}/exhibitions/feed.xml"
      end
    }.merge custom_feeds

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
end
