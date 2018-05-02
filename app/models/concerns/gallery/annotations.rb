# frozen_string_literal: true

class Gallery
  # Annotations support for galleries
  module Annotations
    extend ActiveSupport::Concern

    included do
      after_destroy :destroy_annotations, if: :annotate_records?

      set_callback :set_images, :after, :store_annotations, if: :store_annotations_after_set_images?
      set_callback :set_images, :after, :destroy_annotations, if: :destroy_annotations_after_set_images?

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
      Rails.application.config.x.gallery.annotation_link_resource_host ||
        ENV['HTTP_HOST'] ||
        'www.europeana.eu'
    end

    def needed_annotation_targets
      @needed_annotation_targets ||= images.map(&:annotation_target)
    end

    def needs_annotation_for_target?(target)
      annotation_target_included?(target, needed_annotation_targets)
    end

    def needs_annotation?(annotation)
      needs_annotation_for_target?(annotation.target.with_indifferent_access)
    end

    def existing_annotation_targets
      @existing_annotation_targets ||= annotations.map(&:target).map(&:with_indifferent_access)
    end

    def has_annotation_for_target?(target)
      annotation_target_included?(target, existing_annotation_targets)
    end

    def annotation_target_included?(target, collection)
      collection.any? do |existing|
        existing[:source] == target[:source] &&
          existing[:scope] == target[:scope]
      end
    end

    def annotation_api_user_token
      Rails.application.config.x.europeana[:annotations].api_user_token_gallery || ''
    end

    def store_annotations
      StoreGalleryAnnotationsJob.perform_later(slug)
    end

    def destroy_annotations
      StoreGalleryAnnotationsJob.perform_later(slug, delete_all: true)
    end

    def store_annotations_after_set_images?
      published? && annotate_records?
    end

    def destroy_annotations_after_set_images?
      !published? && annotate_records?
    end
  end
end
