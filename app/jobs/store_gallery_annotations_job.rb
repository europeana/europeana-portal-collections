# frozen_string_literal: true

##
# Creates and deletes annotations via the Annotations API representing the
# inclusion in a gallery of Europeana items.
#
# TODO: write specs
# TODO: do any of these methods belong in `AnnotationsApiConsumer`?
# TODO: ideally this job should be deferred from execution if any other instances
#       of the job are already running for the same value of gallery_id_or_param
class StoreGalleryAnnotationsJob < ActiveJob::Base
  include Europeana::AnnotationsApiConsumer

  queue_as :annotations

  # @param gallery_id_or_param [Integer] ID of the `Gallery` to store annotations for
  # @param gallery_id_or_param [String] `Gallery#to_param` value of the gallery
  #   to delete annotations for
  def perform(gallery_id_or_param)
    case gallery_id_or_param
    when Integer
      @gallery = Gallery.find(gallery_id_or_param)
    when String
      @gallery_url = gallery_url_for_param(gallery_id_or_param)
      @gallery_annotation_targets = []
    else
      fail ArgumentError, "Expected Integer or String for gallery_id_or_param, got #{gallery_id_or_param.class}"
    end

    @api_annotations = annotations_for_gallery

    delete_annotations
    create_annotations
  end

  protected

  # TODO: handle pagination if more than 100 items (if possible in `Gallery`)
  def annotations_for_gallery
    search_response = annotations_search_for_gallery
    return [] unless search_response.key?('items')
    annotations_from_search_response(search_response)
  end

  def annotations_search_for_gallery
    Europeana::API.annotation.search(annotations_api_search_params(find_annotations_local_params))
  end

  def find_annotations_local_params
    @find_annotations_local_params ||= begin
      {
        qf: [
          'creator_name:"Europeana.eu Gallery"',
          'link_relation:isGatheredInto',
          'motivation:linking',
          %(link_resource_uri:"#{gallery_url}")
        ]
      }
    end
  end

  def gallery_url
    @gallery_url ||= gallery_url_for_param(@gallery.to_param)
  end

  # TODO do not hard-code, but use deployment's URL, without locale?
  def gallery_url_for_param(gallery_param)
    "https://www.europeana.eu/portal/explore/galleries/#{gallery_param}"
  end

  def gallery_annotation_targets
    @gallery_annotation_targets ||= begin
      @gallery.images.map do |gallery_image|
        annotation_target_for_record(gallery_image.europeana_record_id)
      end
    end
  end

  # TODO move to separate job?
  def create_annotations
    gallery_annotation_targets.each do |target|
      unless annotation_targets.include?(target)
        logger.info("Creating annotation linking #{target} to #{gallery_url}".green.bold)
        body = annotation_body(target)
        response = Europeana::API.annotation.create(user_authenticated_params.merge(body: body.to_json))
      end
    end
  end

  # TODO move to separate job?
  def delete_annotations
    @api_annotations.each do |anno|
      unless gallery_annotation_targets.include?(anno['target'])
        logger.info("Deleting annotation #{anno['id']}".red.bold)
        split_anno_id = anno['id'].split('/')

        anno_delete_params = {
          provider: split_anno_id[-2],
          id: split_anno_id[-1],
        }.reverse_merge(user_authenticated_params)

        response = Europeana::API.annotation.delete(anno_delete_params)
      end
    end
  end

  def annotation_body(target)
    {
      motivation: 'linking',
      body: {
        '@graph' => {
          '@context' => 'http://www.europeana.eu/schemas/context/edm.jsonld',
          isGatheredInto: gallery_url,
          id: target
        }
      },
      target: target
    }
  end

  def user_authenticated_params
    {
      userToken: Rails.application.config.x.europeana[:annotations].api_user_token_gallery || ''
    }.reverse_merge(annotations_api_env_params)
  end

  def annotation_targets
    @api_annotations.map { |anno| anno[:target] }
  end
end
