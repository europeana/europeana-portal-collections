# frozen_string_literal: true

class Gallery < ActiveRecord::Base
  NUMBER_OF_IMAGES = 6..48

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
  # @todo move this into a configurable class method in `IsCategorisable`
  validate :validate_number_of_categorisations
  validate :validate_image_source_items

  acts_as_url :title, url_attribute: :slug, only_when_blank: true,
                      allow_duplicates: false

  default_scope { includes(:translations) }

  before_save :ensure_unique_title, :clear_api_responses
  after_save :set_images_from_portal_urls

  attr_writer :image_portal_urls

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
  end

  # Double newline separated list of image record URLs for use in a textarea
  # input field in the CMS.
  def image_portal_urls
    @image_portal_urls ||= images.map(&:portal_url).join("\n\n")
  end

  def search_api_query_for_images
    self.class.search_api_query_for_images(images)
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
        matched_ids = []
        record_ids.each_with_index do |record_id, i|
          image_url = response_items.detect { |record| record['id'] == record_id }['edmIsShownBy'].first
          GalleryImage.find_or_create_by!(gallery: self, europeana_record_id: record_id, image_url: image_url).tap do |image|
            image.update_attributes(position: i + 1)
            matched_ids << image.id
          end
        end
        images.where.not(id: matched_ids).delete_all
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

  def validate_number_of_image_portal_urls
    incoming_urls = enumerable_image_portal_urls.size
    unless NUMBER_OF_IMAGES.cover?(incoming_urls)
      errors.add(:image_portal_urls, "must include #{NUMBER_OF_IMAGES.first}-#{NUMBER_OF_IMAGES.last} URLs, not #{incoming_urls}")
    end
  end

  # This validator will make a Europeana Search API request to check that all
  # records coming from `image_portal_urls` meet certain minimum criteria:
  # * is returned by the API
  # * has an edm:isShownBy
  # * has type="IMAGE"
  # Records not meeting these will be invalid.
  #
  # While is is not ideal making HTTP requests here in the model, we need
  # to prevent creation of galleries not having displayable media.
  #
  # This validation will exit early if any other problems are observed with
  # the `image_portal_urls`, leaving this costly validation until the URLs are
  # otherwise valid.
  #
  # @todo these validations and others on image_portal_urls belong in `GalleryImage`
  def validate_image_source_items
    return if errors[:image_portal_urls].any?

    record_id_url_pairs.each_pair do |url, record_id|
      item = response_items.detect { |response_item| response_item['id'] == record_id }
      if item.blank?
        errors.add(:image_portal_urls, %(item not found by the API: "#{url}"))
      else
        unless item['edmIsShownBy'].present?
          errors.add(:image_portal_urls, %(item has no edm:isShownBy: "#{url}"))
        end
        unless item['type'] == 'IMAGE'
          errors.add(:image_portal_urls, %(item has type "#{item['type']}", not "IMAGE": "#{url}"))
        end
      end
    end
  end

  def response_items
    @response_items ||= begin
      api_query = Europeana::Record.search_api_query_for_record_ids(record_id_url_pairs.values)
      Europeana::API.record.search(query: api_query, profile: 'rich', rows: 100)['items'] || []
    end
  end

  def record_id_url_pairs
    @record_id_url_pairs ||= begin
      enumerable_image_portal_urls.each_with_object({}) do |url, map|
        map[url] = Europeana::Record.id_from_portal_url(url)
      end
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

  def clear_api_responses
    @record_id_url_pairs = nil
    @response_items = nil
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
