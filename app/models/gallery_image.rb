# frozen_string_literal: true

class GalleryImage < ActiveRecord::Base
  belongs_to :gallery, inverse_of: :images, touch: true

  # EDM record types from which gallery images may be created
  ALLOWED_TYPES = %w(IMAGE TEXT).freeze

  # Source (Search API) data from which this image is derived
  attr_accessor :source

  validates :gallery, presence: true
  validates :europeana_record_id,
            presence: true, format: { with: Europeana::Record::ID_PATTERN }
  validates :url, presence: true

  delegate :annotation_target_uri, :portal_url, to: :europeana_record

  def europeana_record
    @europeana_record ||= Europeana::Record.new(europeana_record_id)
  end

  def annotation
    @annotation ||= Europeana::Annotation.new(annotation_attributes)
  end

  def annotation_attributes
    {
      motivation: 'linking',
      body: {
        '@graph' => {
          '@context' => 'http://www.europeana.eu/schemas/context/edm.jsonld',
          isGatheredInto: gallery&.annotation_link_resource_uri,
          id: annotation_target_uri
        }
      },
      target: annotation_target_uri
    }
  end

  # Validates the content of +source+ as acceptable for creation of a gallery image
  #
  # This validation is *not* run by the +validate+ callback on the image model,
  # but called during validation of a +Gallery+.
  #
  # @see Gallery#validate_image_source_items
  def validate_source
    if source.blank?
      errors.add(:source, %(item not found by the API: "#{url}"))
    else
      unless source['edmIsShownBy'].present?
        errors.add(:source, %(item has no edm:isShownBy: "#{url}"))
      end
      unless ALLOWED_TYPES.include?(source['type'])
        errors.add(:source, %(item has type "#{source['type']}", not #{ALLOWED_TYPES.join(' or ')}: "#{url}"))
      end
    end
  end
end
