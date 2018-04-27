# frozen_string_literal: true

class GalleryImage
  module Annotation
    extend ActiveSupport::Concern

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
end
