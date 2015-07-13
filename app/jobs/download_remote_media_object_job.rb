require 'open-uri'

# @todo deal with 404's
# @todo follow redirects?
class DownloadRemoteMediaObjectJob < ActiveJob::Base
  queue_as :default

  def perform(url)
    url_hash = MediaObject.hash_source_url(url)
    return unless MediaObject.find_by_source_url_hash(url_hash).nil?

    media_object = MediaObject.new(source_url: url)
    open(url) do |io|
      media_object.file = io
    end
    media_object.file_file_name = URI.parse(url).path.split('/').last
    media_object.save
  end
end
