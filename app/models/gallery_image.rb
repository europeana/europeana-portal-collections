# frozen_string_literal: true

class GalleryImage < ActiveRecord::Base
  belongs_to :gallery, inverse_of: :images, touch: true

  validates :gallery, presence: true
  validates :europeana_record_id,
            presence: true, format: { with: Europeana::Record::ID_PATTERN }

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
end
