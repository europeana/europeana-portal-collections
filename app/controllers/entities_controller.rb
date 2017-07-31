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
    unless body_cached?
      @entity = Europeana::API.
                entity.fetch(entities_api_fetch_params(params[:type], params[:namespace], params[:identifier]))
      @items_by_query = build_query_items_by(params)
    end

    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end

  private

  def body_cache_key
    ['entities', params[:type], params[:namespace], params[:identifier]].join('/')
  end

  def build_query_items_by(params)
    suffix = "#{params[:type]}/#{params[:namespace]}/#{params[:identifier]}"
    creator = build_proxy_dc('creator', 'http://data.europeana.eu', suffix)
    contributor = build_proxy_dc('contributor', 'http://data.europeana.eu', suffix)
    "#{creator} OR #{contributor}"
  end

  def build_proxy_dc(name, url, suffix)
    "proxy_dc_#{name}:\"#{url}/#{suffix}\""
  end
end
