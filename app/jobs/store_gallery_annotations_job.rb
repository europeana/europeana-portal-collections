# frozen_string_literal: true

##
# Creates and deletes annotations via the Annotations API representing the
# inclusion in a gallery of Europeana items.
#
# TODO: write specs
# TODO: ideally this job should be deferred from execution if any other instances
#       of the job are already running for the same value of gallery_id_or_param
# TODO: create a job and rake task to queue storing/deleting annotations for all
#       existing galleries
class StoreGalleryAnnotationsJob < ActiveJob::Base
  include Europeana::AnnotationsApiConsumer

  queue_as :annotations

  attr_reader :gallery

  # @param gallery_slug [String] slug of the gallery
  # @param delete_all [TrueClass,FalseClass] if true, just delete all gallery annotations
  def perform(gallery_slug, delete_all: false)
    fail "Gallery annotations functionality is not configured." unless Gallery.annotate_records?
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

  # TODO: handle pagination if more than 100 items (if possible in `Gallery`)
  def api_annotations
    @api_annotations ||= annotations_from_search_response(find_annotations)
  end

  def find_annotations
    search_params = annotations_api_search_params.merge(gallery.annotation_search_params)
    Europeana::API.annotation.search(search_params)
  end

  # TODO move to separate job?
  def create_annotations
    gallery.images.each do |image|
      unless api_annotation_targets.include?(image.annotation_target)
        logger.info("Creating annotation linking #{image.annotation_target} to #{gallery.annotation_link_resource_uri}".green.bold)
        Europeana::API.annotation.create(create_annotation_api_params(image))
      end
    end
  end

  def create_annotation_api_params(image)
    body = image.annotation_body
    annotations_api_env_params_with_token.merge(body: body.to_json)
  end

  # TODO move to separate job?
  def delete_annotations
    api_annotations.each do |annotation|
      next unless delete_annotation?(annotation)
      logger.info("Deleting annotation #{annotation['id']}".red.bold)
      Europeana::API.annotation.delete(annotations_api_delete_params(annotation))
    end
  end

  def delete_annotation?(annotation)
    @delete_all || !gallery.image_annotation_targets.include?(annotation['target'])
  end

  def api_annotation_targets
    api_annotations.map { |anno| anno[:target] }
  end
end
