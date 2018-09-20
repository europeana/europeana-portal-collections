# frozen_string_literal: true

require 'digest/md5'

class MediaObject < ActiveRecord::Base
  has_attached_file :file, processors: %i(thumbnail image_optimizer)
  attr_accessor :delete_file
  before_validation { file.clear if delete_file == '1' }

  has_one :browse_entry, dependent: :nullify
  has_one :hero_image, dependent: :nullify
  has_one :promotion, dependent: :nullify, class_name: 'Link::Promotion'

  do_not_validate_attachment_file_type :file

  before_save :hash_source_url!, if: :source_url?
  after_save :touch_associated

  def hash_source_url!
    self.source_url_hash = self.class.hash_source_url(source_url)
  end

  def self.hash_source_url(source_url)
    Digest::MD5.hexdigest(source_url)
  end

  def touch_associated
    browse_entry.touch if browse_entry.present?
    hero_image.touch if hero_image.present?
    promotion.touch if promotion.present?
  end
end
