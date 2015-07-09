require 'digest/md5'

class MediaObject < ActiveRecord::Base
  before_save :hash_source_url!, if: :source_url?
  has_attached_file :file,
    styles: { small: '200>', medium: '400>', large: '600>' } # max-width

  def hash_source_url!
    self.source_url_hash = Digest::MD5.hexdigest(source_url)
  end
end
