require 'open-uri'

# @todo deal with 404's
# @todo follow redirects?
class DownloadRemoteMediaObjectJob < ApplicationJob
  queue_as :high_priority

  def perform(url)
    url_hash = MediaObject.hash_source_url(url)

    media_object = MediaObject.find_or_initialize_by(source_url_hash: url_hash)
    if media_object.new_record?
      media_object.source_url = url
    else
      return unless media_object.file.blank?
    end

    open(url) do |io|
      media_object.file = io
    end
    media_object.file_file_name = URI.parse(url).path.split('/').last
    media_object.save
  end
end
