# frozen_string_literal: true
class EntitiesController < ApplicationController
  include CacheHelper
  include Europeana::EntitiesApiConsumer

  attr_reader :body_cache_key

  def suggest
    render json: Europeana::API.entity.suggest(entities_api_suggest_params(params[:text]))
  end

  def show
    authorize! :show, :entity

    @body_cache_key = body_cache_key
    # TODO: having a cached body should not prevent the URL slug enforcement redirect
    unless body_cached?
      @api_type = entities_api_type(params[:type])
      @entity = Europeana::API.
                entity.fetch(entities_api_fetch_params(@api_type, 'base', params[:id]))

      expected_slug = entity_url_slug(@entity)
      unless expected_slug == params[:slug]
        redirect_to url_for(slug: expected_slug, format: params[:format])
        return
      end

      @items_by_query = build_query_items_by(params)
    end

    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end

  private

  def body_cache_key
    ['entities', params[:type], params[:id]].join('/')
  end

  def build_query_items_by(params)
    suffix = "#{@api_type}/base/#{params[:id]}"
    creator = build_proxy_dc('creator', 'http://data.europeana.eu', suffix)
    contributor = build_proxy_dc('contributor', 'http://data.europeana.eu', suffix)
    "#{creator} OR #{contributor}"
  end

  def build_proxy_dc(name, url, suffix)
    %(proxy_dc_#{name}:"#{url}/#{suffix}")
  end
end
