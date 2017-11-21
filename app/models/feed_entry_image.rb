# frozen_string_literal: true

class FeedEntryImage < Europeana::Feeds::FeedEntryImage
  def thumbnail_url
    media_object&.file&.url(:medium)
  end

  def media_object
    @media_object ||= begin
      return if url.nil?
      hash = MediaObject.hash_source_url(url)
      MediaObject.find_by_source_url_hash(hash)
    end
  end
end
