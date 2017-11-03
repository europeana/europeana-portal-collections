# frozen_string_literal: true

class Gallery
  ##
  # Annotations support for galleries
  module Annotations
    def annotations
      @annotations ||= Europeana::Annotation.find(annotations_search_params)
    end

    def annotations_search_params
      {
        qf: [
          'creator_name:"Europeana.eu Gallery"',
          'link_relation:isGatheredInto',
          'motivation:linking',
          %(link_resource_uri:"#{annotation_link_resource_uri}")
        ]
      }
    end

    # TODO: do not hard-code, but use deployment's URL, without locale? or make
    #       configurable in env var?
    def annotation_link_resource_uri
      @annotation_link_resource_uri ||= "https://www.europeana.eu/portal/explore/galleries/#{slug}"
    end

    def image_annotation_targets
      @image_annotation_targets ||= images.map(&:annotation_target_uri)
    end
  end
end
