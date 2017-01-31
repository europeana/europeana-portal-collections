# frozen_string_literal: true
class GalleriesController < ApplicationController
  def index
    @galleries = Gallery.includes(:images).published
    @documents = search_api_for_image_metadata(gallery_images_for_foyer(@galleries))
  end

  def show
    @gallery = Gallery.find_by_slug(params[:id])
    @documents = search_api_for_image_metadata(@gallery.images)
  end

  protected

  def gallery_images_for_foyer(galleries)
    galleries.map { |gallery| gallery.images.first(3) }.flatten
  end

  # @return [Array<Europeana::Blacklight::Document>]
  def search_api_for_image_metadata(images)
    search_results(blacklight_api_params_for_images(images)).last
  end

  def blacklight_api_params_for_images(images)
    { q: search_api_query_for_images(images), per_page: 100 }
  end

  def search_api_query_for_images(images)
    'europeana_id:("' + images.map(&:europeana_record_id).join('" OR "') + '")'
  end
end