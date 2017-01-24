# frozen_string_literal: true
class Gallery < ActiveRecord::Base
  include HasPublicationStates

  has_many :images, -> { order(:position) }, class_name: 'GalleryImage',
    dependent: :destroy, inverse_of: :gallery
  accepts_nested_attributes_for :images, allow_destroy: true

  translates :title, :description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  has_paper_trail

  validates :title, presence: true, length: { maximum: 60 }
  validates :description, length: { maximum: 280 }

  default_scope { includes(:translations) }

  after_save :set_images_from_record_urls

  attr_writer :image_record_urls

  # Double newline separated list of image record URLs for use in a textarea
  # input field in the CMS.
  def image_record_urls
    images.map(&:record_url).join("\n\n")
  end

  protected

  # CRUD images from a newline separated list of record URLs, to set images
  # and their positioning from a space-separated list of URLs, as would come
  # from a textarea input field in the CMS.
  def set_images_from_record_urls
    transaction do
      @image_record_urls.strip.split(/\s+/).compact.tap do |urls|
        urls.each_with_index do |url, i|
          image = images.find_or_create_by(record_url: url)
          image.update_attributes(position: i + 1)
        end
        images.where.not(record_url: urls).destroy_all
      end
    end
  end
end
