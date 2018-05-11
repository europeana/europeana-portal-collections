# frozen_string_literal: true

# TODO: prevent running of Cache::Expiry::GlobalNavJob til after set_images
class Gallery < ActiveRecord::Base
  NUMBER_OF_IMAGES = 6..48

  define_callbacks :set_images

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

  before_save if: :image_portal_urls_changed? do
    self.image_errors = nil
  end

  before_save :ensure_unique_title
  after_save :enqueue_gallery_displayability_job, if: :image_portal_urls_changed?

  after_initialize do
    if image_errors.present?
      image_errors.values.flatten.each do |err|
        errors.add(:image_portal_urls_text, err)
      end
    end
  end

  ##
  # Constructs a Search API query for al set of gallery images.
  #
  # @param images [Enumerable<GalleryImage>]
  # @return [String]
  # @see Europeana::Record.search_api_query_for_record_ids
  class << self
    def search_api_query_for_images(images)
      Europeana::Record.search_api_query_for_record_ids(images.map(&:europeana_record_id))
    end

    def valid_image_count?(count)
      NUMBER_OF_IMAGES.cover?(count)
    end
  end

  def search_api_query_for_images
    self.class.search_api_query_for_images(images)
  end

  def to_param
    slug
  end

  def image_portal_urls_text
    @image_portal_urls_text ||= image_portal_urls&.join("\n\n")
  end

  def image_portal_urls_text=(value)
    self.image_portal_urls = value&.strip&.split(/\s+/)&.compact || []
    @image_portal_urls_text = value
  end

  def image_portal_urls
    super || images.map(&:portal_url)
  end

  # Create/update/delete images
  #
  # This is *not* called during +Gallery+ persistence, as thorough validation
  # needs first to be performed in the background, via +GalleryDisplayabilityJob+.
  #
  # @param portal_urls [Array<String>]
  def set_images(portal_urls = image_portal_urls)
    run_callbacks :set_images do
      transaction do
        associated_image_ids = []
        portal_urls.each_with_index do |portal_url, i|
          GalleryImage.find_or_create_from_portal_url(portal_url, gallery: self).tap do |image|
            image.update_attributes(position: i + 1)
            associated_image_ids << image.id
          end
        end
        images.where.not(id: associated_image_ids).delete_all
      end
    end
  end

  def publishable?
    self.class.valid_image_count?(images.size)
  end

  def enqueue_gallery_displayability_job
    GalleryDisplayabilityJob.perform_later(id)
  end

  protected

  def validate_image_portal_urls
    return unless image_portal_urls.present?
    image_portal_urls.each do |url|
      if Europeana::Record.id_from_portal_url(url).nil?
        errors.add(:image_portal_urls_text, %(not a Europeana record URL: "#{url}"))
      end
    end
  end

  def validate_number_of_image_portal_urls
    incoming_url_count = image_portal_urls&.size || 0
    unless self.class.valid_image_count?(incoming_url_count)
      errors.add(:image_portal_urls_text, "must include #{NUMBER_OF_IMAGES.first}-#{NUMBER_OF_IMAGES.last} URLs, not #{incoming_url_count}")
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
