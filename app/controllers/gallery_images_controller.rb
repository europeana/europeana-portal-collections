# frozen_string_literal: true
class GalleryImagesController < ApplicationController
  def show
    @gallery = Gallery.find_by_slug(params[:gallery_slug])
    @image = @gallery.images.where(position: params[:position]).first
    @response, @document = fetch(@image.europeana_record_id, api_query_params)

    respond_to do |format|
      format.json
    end
  end

  protected

  def api_query_params
    params.slice(:api_url)
  end
end
