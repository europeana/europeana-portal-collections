# frozen_string_literal: true
class GalleryImage < ActiveRecord::Base
  belongs_to :gallery, inverse_of: :images, touch: true

  validates :gallery, presence: true
  validates :europeana_record_id,
            presence: true, format: { with: Europeana::Record::ID_PATTERN }

  ##
  # Gets the URL of the item on the portal that this gallery image represents
  def portal_url
    @portal_url ||= Europeana::Record.portal_url_from_id(europeana_record_id)
  end

  def annotation_target
    @annotation_target ||= Europeana::Record.annotation_target(europeana_record_id)
  end

  def annotation_body
    @annotation_body ||= begin
      {
        motivation: 'linking',
        body: {
          '@graph' => {
            '@context' => 'http://www.europeana.eu/schemas/context/edm.jsonld',
            isGatheredInto: gallery.annotation_link_resource_uri,
            id: annotation_target
          }
        },
        target: annotation_target
      }
    end
  end
end
