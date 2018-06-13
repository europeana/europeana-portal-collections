# frozen_string_literal: true

class GalleriesController < ApplicationController
  include CacheHelper
  include HomepageHeroImage
  include PaginatedController

  self.pagination_per_default = 24

  attr_reader :body_cache_key

  def index
    @galleries = Gallery.includes(:images).published.order(published_at: :desc).
                 page(pagination_page).per(pagination_per).with_topic(gallery_topic)
    @selected_topic = gallery_topic
    @hero_image = homepage_hero_image

    @body_cache_key = foyer_body_cache_key(topic: @selected_topic, per: @galleries.limit_value, page: @galleries.current_page)

    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
    @gallery = Gallery.find_by_slug(params[:slug])
    authorize! :show, @gallery

    @body_cache_key = 'explore/' + @gallery.cache_key
    @documents = search_api_for_image_metadata unless body_cached?

    respond_to do |format|
      format.html
    end
  end

  protected

  def foyer_body_cache_key(topic:, per:, page:)
    last_galleries_edit_int = Gallery.order(updated_at: :desc).first.updated_at.to_i
    "explore/galleries.#{request.format.to_sym}/#{last_galleries_edit_int}/#{topic}/#{per}/#{page}/"
  end

  # @return [Array<Europeana::Blacklight::Document>]
  def search_api_for_image_metadata
    return [] if @gallery.images.blank?
    search_results(blacklight_api_params_for_images).last
  end

  def blacklight_api_params_for_images
    { q: @gallery.search_api_query_for_images, per_page: 100 }
  end

  def gallery_topic
    params[:theme] || 'all'
  end
end
