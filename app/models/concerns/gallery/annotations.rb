# frozen_string_literal: true

class Gallery
  module Annotations
    extend ActiveSupport::Concern

    def annotation_search_params
      @annotation_search_params ||= begin
        {
          qf: [
            'creator_name:"Europeana.eu Gallery"',
            'link_relation:isGatheredInto',
            'motivation:linking',
            %(link_resource_uri:"#{annotation_link_resource_uri}")
          ]
        }
      end
    end

    # TODO: do not hard-code, but use deployment's URL, without locale? or make
    #       configurable in env var?
    def annotation_link_resource_uri
      @annotation_link_resource_uri ||= "https://www.europeana.eu/portal/explore/galleries/#{slug}"
    end

    def image_annotation_targets
      @image_annotation_targets ||= images.map(&:annotation_target)
    end
  end
end
