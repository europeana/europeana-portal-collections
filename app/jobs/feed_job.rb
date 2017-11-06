# frozen_string_literal: true

class FeedJob < Europeana::Feeds::FetchJob
  # Global nav uses some feeds, and is cached so needs to be expired when those
  # feeds are updated.
  # Cached pages need to be expired should they be using the updated feed.
  after_perform do
    if @updated
      if @download_media
        @feed.entries.each do |entry|
          img_url = FeedEntryImage.new(entry).media_object_url
          DownloadRemoteMediaObjectJob.perform_later(img_url) unless img_url.nil?
        end
      end
      Cache::Expiry::FeedAssociatedJob.perform_later(@url)
    end
  end
end