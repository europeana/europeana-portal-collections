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
    images = gallery_images_for_foyer(@galleries)
    @hero_image = homepage_hero_image

    @body_cache_key = foyer_body_cache_key(topic: @selected_topic, per: @galleries.limit_value, page: @galleries.current_page)
    @documents = search_api_for_image_metadata(images) unless body_cached?

    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
    @gallery = Gallery.find_by_slug(params[:slug])
    authorize! :show, @gallery
    images = @gallery.images

    @body_cache_key = 'explore/' + @gallery.cache_key

    if body_cached?
      @hero_image_url = gallery_hero_image_from_cache
    else
      @documents = search_api_for_image_metadata(images)
      set_gallery_hero_image_cache(images.first)
    end

    respond_to do |format|
      format.html
    end
  end

  protected

  def foyer_body_cache_key(topic:, per:, page:)
    last_galleries_edit_int = Gallery.order(updated_at: :desc).first.updated_at.to_i
    "explore/galleries.#{request.format.to_sym}/#{last_galleries_edit_int}/#{topic}/#{per}/#{page}/"
  end

  def gallery_images_for_foyer(galleries)
    galleries.map { |gallery| gallery.images.first(3) }.flatten
  end

  # @return [Array<Europeana::Blacklight::Document>]
  def search_api_for_image_metadata(images)
    return [] if images.blank?
    search_results(blacklight_api_params_for_images(images)).last
  end

  def gallery_hero_image_from_cache
    Rails.cache.fetch(cache_key(@body_cache_key) + '/hero_image_url')
  end

  def set_gallery_hero_image_cache(image)
    image_document = @documents.detect { |document| document.fetch(:id, nil) == image.europeana_record_id }
    @hero_image_url = image_document['edmIsShownBy'].first
    Rails.cache.write(cache_key(@body_cache_key) + '/hero_image_url', @hero_image_url, expires_in: 24.hours + 1.minute)
  end

  def blacklight_api_params_for_images(images)
    { q: Gallery.search_api_query_for_images(images), per_page: 100 }
  end

  def search_api_query_for_images(images)
    'europeana_id:("' + images.map(&:europeana_record_id).join('" OR "') + '")'
  end

  def gallery_topic
    params[:theme] || 'all'
  end
end
