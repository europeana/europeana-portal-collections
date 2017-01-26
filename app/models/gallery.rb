# frozen_string_literal: true
class Gallery < ActiveRecord::Base
  include HasPublicationStates

  has_many :images, -> { order(:position) },
    class_name: 'GalleryImage', dependent: :destroy, inverse_of: :gallery
  accepts_nested_attributes_for :images, allow_destroy: true

  translates :title, :description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations, allow_destroy: true

  has_paper_trail

  validates :title, presence: true, length: { maximum: 60 }
  validates :description, length: { maximum: 280 }
  validate :validate_image_record_urls

  default_scope { includes(:translations) }

  after_save :set_images_from_record_urls

  attr_writer :image_record_urls

  # Double newline separated list of image record URLs for use in a textarea
  # input field in the CMS.
  def image_record_urls
    @image_record_urls ||= images.map(&:url).join("\n\n")
  end

  protected

  # Create/update/delete images from a newline separated list of record URLs,
  # to set images and their positioning from a space-separated list of URLs,
  # as would come from a textarea input field in the CMS.
  def set_images_from_record_urls
    transaction do
      @image_record_urls.strip.split(/\s+/).compact.tap do |urls|
        urls.each_with_index do |url, i|
          images.detect { |image| image.url == url }.tap do |image|
            image ||= GalleryImage.create(gallery: self, url: url)
            image.update_attributes(position: i + 1)
          end
        end
        images.reject { |image| urls.include?(image.url) }.each(&:destroy)
      end
    end
  end

  def validate_image_record_urls
    return unless @image_record_urls.present?
    @image_record_urls.strip.split(/\s+/).compact.each do |url|
      if Europeana::Record.europeana_id_from_url(url).nil?
        errors.add(:image_record_urls, %(not a Europeana record URL: "#{url}"))
      end
    end
  end
end
