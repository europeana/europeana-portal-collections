# frozen_string_literal: true
##
# Creates and deletes annotations via the Annotations API representing the
# inclusion in a gallery of Europeana items.
class StoreGalleryAnnotationsJob < ActiveJob::Base
  include Europeana::AnnotationsApiConsumer

  queue_as :annotations

  # @param gallery_id [Fixnum] ID of the `Gallery` to store annotations for
  def perform(gallery_id)
    @gallery = Gallery.find(gallery_id)
    @annotations = find_annotations
    delete_annotations
    create_annotations
  end

  protected

  # @todo restrict to annotations linking items to the gallery
  # @todo handle pagination
  def find_annotations
    @gallery.images.map do |gallery_image|
      annotations_for_record(gallery_image.europeana_record_id, { qf: ['motivation:linking'] })
    end.flatten.compact.select do |anno|
      anno[:body] && anno[:body]['@graph'] && (anno[:body]['@graph']['isGatheredInto'] == gallery_url)
    end
  end

  # @todo do not hard-code, but use deployment's URL, without locale
  def gallery_url
    @gallery_url ||= "http://www.europeana.eu/portal/explore/galleries/#{@gallery.to_param}"
  end

  def gallery_annotation_targets
    @gallery_annotation_targets ||= begin
      @gallery.images.map do |gallery_image|
        annotation_target_for_record(gallery_image.europeana_record_id)
      end
    end
  end

  # @todo move to separate job
  def delete_annotations
    @annotations.each do |anno|
      unless gallery_annotation_targets.include?(anno['target'])
        logger.debug("Deleting annotation #{anno['id']}")
      end
    end
  end

  # @todo move to separate job
  def create_annotations
    gallery_annotation_targets.each do |target|
      unless annotation_targets.include?(target)
        logger.debug "Creating annotation linking #{target} to #{gallery_url}"
      end
    end
  end

  def annotation_targets
    annotation_targets ||= @annotations.map { |anno| anno[:target] }
  end
end
