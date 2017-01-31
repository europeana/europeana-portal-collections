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
  validates :slug, presence: true
  validate :validate_image_portal_urls

  acts_as_url :title, url_attribute: :slug, only_when_blank: true,
                      allow_duplicates: false

  default_scope { includes(:translations) }

  before_save :ensure_unique_title
  after_save :set_images_from_portal_urls

  attr_writer :image_portal_urls

  # Double newline separated list of image record URLs for use in a textarea
  # input field in the CMS.
  def image_portal_urls
    @image_portal_urls ||= images.map(&:portal_url).join("\n\n")
  end

  def to_param
    slug
  end

  protected

  # Create/update/delete images from a newline separated list of record URLs,
  # to set images and their positioning from a space-separated list of URLs,
  # as would come from a textarea input field in the CMS.
  def set_images_from_portal_urls
    transaction do
      enumerable_image_portal_urls.map { |url| Europeana::Record.id_from_portal_url(url) }.tap do |record_ids|
        record_ids.each_with_index do |record_id, i|
          GalleryImage.find_or_create_by(gallery: self, europeana_record_id: record_id).tap do |image|
            image.update_attributes(position: i + 1)
          end
        end
        images.where.not(europeana_record_id: record_ids).destroy_all
      end
    end
  end

  def enumerable_image_portal_urls
    image_portal_urls.strip.split(/\s+/).compact
  end

  def validate_image_portal_urls
    return unless @image_portal_urls.present?
    enumerable_image_portal_urls.each do |url|
      if Europeana::Record.id_from_portal_url(url).nil?
        errors.add(:image_portal_urls, %(not a Europeana record URL: "#{url}"))
      end
    end
  end

  def ensure_unique_title
    i = 0
    unique_title = title
    while !Gallery.where(title: unique_title).where.not(id: id).blank?
      i = i + 1
      unique_title = "#{title} #{i}"
    end
    self.title = unique_title
  end
end
