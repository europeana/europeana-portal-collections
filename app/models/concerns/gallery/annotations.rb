# frozen_string_literal: true

class Gallery
  # Annotations support for galleries
  module Annotations
    extend ActiveSupport::Concern

    included do
      after_save :store_annotations, if: :store_annotations_after_save?
      after_save :destroy_annotations, if: :destroy_annotations_after_save?

      after_destroy :destroy_annotations, if: :annotate_records?

      delegate :annotate_records?, to: :class
    end

    class_methods do
      # Should we write annotations to the Europeana Annotations API linking
      # records to the galleries they are included in?
      #
      # @return [Boolean]
      def annotate_records?
        Rails.application.config.x.europeana[:annotations].api_user_token_gallery.present? &&
          Rails.application.config.x.enable.gallery_annotations.present?
      end
    end

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

    private

    def store_annotations
      StoreGalleryAnnotationsJob.perform_later(slug)
    end

    def destroy_annotations
      StoreGalleryAnnotationsJob.perform_later(slug, delete_all: true)
    end

    def store_annotations_after_save?
      published? && annotate_records?
    end

    def destroy_annotations_after_save?
      !published? && annotate_records?
    end
  end
end
