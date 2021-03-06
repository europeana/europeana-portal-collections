# frozen_string_literal: true

##
# Creates and deletes annotations via the Annotations API representing the
# inclusion in a gallery of Europeana items.
#
# TODO: ideally this job should be deferred from execution if any other instances
#       of the job are already running for the same value of gallery_slug
class StoreGalleryAnnotationsJob < ActiveJob::Base
  queue_as :annotations

  attr_reader :gallery

  # @param gallery_slug [String] slug of the gallery
  # @param delete_all [TrueClass,FalseClass] if true, just delete all gallery annotations
  def perform(gallery_slug, delete_all: false)
    fail 'Gallery annotations functionality is not configured.' unless Gallery.annotate_records?
    validate_args_to_perform!(gallery_slug, delete_all: delete_all)

    @delete_all = delete_all
    @gallery = Gallery.where(slug: gallery_slug).first_or_initialize

    delete_annotations
    create_annotations unless delete_all
  end

  protected

  def validate_args_to_perform!(gallery_slug, delete_all:)
    unless gallery_slug.is_a?(String)
      fail ArgumentError, "Expected String for gallery_slug, got #{gallery_slug.class}"
    end
    unless [true, false].include?(delete_all)
      fail ArgumentError, "Expected true or false for delete_all, got #{delete_all.inspect}"
    end
  end

  def create_annotations
    gallery.images.each do |image|
      next if gallery.has_annotation_for_target?(image.annotation_target)
      logger.info("Creating annotation linking #{image.annotation_target_uri} to #{gallery.annotation_link_resource_uri}".green.bold)
      image.annotation.tap do |annotation|
        annotation.api_user_token = gallery.annotation_api_user_token
        annotation.save
      end
    end
  end

  def delete_annotations
    gallery.annotations.each do |annotation|
      next unless delete_annotation?(annotation)
      logger.info("Deleting annotation #{annotation.id}".red.bold)
      annotation.api_user_token = gallery.annotation_api_user_token
      annotation.delete
    end
  end

  def delete_annotation?(annotation)
    @delete_all || !gallery.needs_annotation?(annotation)
  end
end
