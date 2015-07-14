require 'digest/md5'

class MediaObject < ActiveRecord::Base
  has_attached_file :file

  do_not_validate_attachment_file_type :file

  before_save :hash_source_url!, if: :source_url?

  def hash_source_url!
    self.source_url_hash = self.class.hash_source_url(source_url)
  end

  def self.hash_source_url(source_url)
    Digest::MD5.hexdigest(source_url)
  end
end
