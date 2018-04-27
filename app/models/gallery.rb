# frozen_string_literal: true

class Gallery < ActiveRecord::Base
  NUMBER_OF_IMAGES = 6..48

  include Gallery::Annotations
  # TODO: prevent publishing unless images are present
  include HasPublicationStates
  include IsCategorisable
  include IsPermissionable

  scope :with_topic, ->(topic_slug) do
    topic_slug == 'all' ? all : joins(:categorisations, :topics).where(topics: { slug: topic_slug }).distinct
  end

  belongs_to :publisher, foreign_key: 'published_by', class_name: 'User', inverse_of: :galleries
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
  validate :validate_number_of_image_portal_urls
  # TODO: move this into a configurable class method in `IsCategorisable`
  validate :validate_number_of_categorisations

  acts_as_url :title, url_attribute: :slug, only_when_blank: true,
                      allow_duplicates: false

  default_scope { includes(:translations) }

  before_save :ensure_unique_title
  after_save :enqueue_gallery_validation_job

  ##
  # Constructs a Search API query for al set of gallery images.
  #
  # @param images [Enumerable<GalleryImage>]
  # @return [String]
  # @see Europeana::Record.search_api_query_for_record_ids
  class << self
    # TODO: consider how this is affected by hasView support...
    def search_api_query_for_images(images)
      Europeana::Record.search_api_query_for_record_ids(images.map(&:europeana_record_id))
    end
  end

  # Double newline separated list of image record URLs for use in a textarea
  # input field in the CMS.
  def image_portal_urls
    super || images.map(&:portal_url).join("\n\n")
  end

  def search_api_query_for_images
    self.class.search_api_query_for_images(images)
  end

  def to_param
    slug
  end

  def enumerable_image_portal_urls
    image_portal_urls.strip.split(/\s+/).compact
  end

  protected

  # Create/update/delete images from portal URLs in +image_portal_urls+.
  #
  # This is *not* called during +Gallery+ persistence, as thorough validation
  # needs first to be performed in the background, via +
  def set_images_from_portal_urls
    transaction do
      associated_image_ids = []
      enumerable_image_portal_urls.each_with_index do |portal_url, i|
        GalleryImage.find_or_create_from_portal_url(portal_url, gallery: self).tap do |image|
          image.update_attributes(position: i + 1)
          associated_image_ids << image.id
        end
      end
      images.where.not(id: associated_image_ids).delete_all
      update_attribute(image_portal_urls: nil)
    end
  end

  def enqueue_gallery_validation_job
    GalleryValidationJob.perform_later(id)
  end

  def validate_image_portal_urls
    return unless @image_portal_urls.present?
    enumerable_image_portal_urls.each do |url|
      if Europeana::Record.id_from_portal_url(url).nil?
        errors.add(:image_portal_urls, %(not a Europeana record URL: "#{url}"))
      end
    end
  end

  def validate_number_of_image_portal_urls
    incoming_urls = enumerable_image_portal_urls.size
    unless NUMBER_OF_IMAGES.cover?(incoming_urls)
      errors.add(:image_portal_urls, "must include #{NUMBER_OF_IMAGES.first}-#{NUMBER_OF_IMAGES.last} URLs, not #{incoming_urls}")
    end
  end

  def ensure_unique_title
    i = 0
    unique_title = title
    until Gallery.where(title: unique_title).where.not(id: id).blank?
      i += 1
      unique_title = "#{title} #{i}"
    end
    self.title = unique_title
  end

  def validate_number_of_categorisations
    if categorisations.size > 3
      errors.add(:categorisations, 'can have at most 3 topics')
    end
  end

  # Overriding the after_publish method, to track first publication.
  def after_publish
    unless published_at
      self.published_at = DateTime.now
      if ::PaperTrail.whodunnit
        self.publisher = User.find(::PaperTrail.whodunnit)
      end
      save
    end
  end
end
