# frozen_string_literal: true

class GalleryImage
  module Annotation
    extend ActiveSupport::Concern

    included do
      delegate :annotation_target_uri, to: :europeana_record
    end

    def annotation
      @annotation ||= Europeana::Annotation.new(annotation_attributes)
    end

    def annotation_target
      {
        'type': 'SpecificResource',
        'scope': annotation_target_uri,
        'source': url
      }
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
        target: annotation_target
      }
    end
  end
end
