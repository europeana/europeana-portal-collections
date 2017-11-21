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

    def annotation_link_resource_uri
      @annotation_link_resource_uri ||= "https://#{annotation_link_resource_host}/portal/explore/galleries/#{slug}"
    end

    def annotation_link_resource_host
      ENV['HTTP_HOST'] || 'www.europeana.eu'
    end

    def image_annotation_targets
      @image_annotation_targets ||= images.map(&:annotation_target_uri)
    end

    def annotation_api_user_token
      Rails.application.config.x.europeana[:annotations].api_user_token_gallery || ''
    end
  end
end
