# frozen_string_literal: true
class EntitiesController < ApplicationController
  include CacheHelper
  include Europeana::EntitiesApiConsumer

  attr_reader :body_cache_key

  before_action :ensure_entity_page_enabled, only: :show
  before_action :enforce_slug, only: :show

  def suggest
    api_params = entities_api_suggest_params(params.slice(:text, :language))
    api_response = Europeana::API.entity.suggest(api_params)
    render json: api_response
  end

  def show
    @body_cache_key = body_cache_key
    @entity = entity unless body_cached?
    e = EDM::Entity.build(entity_params)

    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end

  private

  # Generate 404 unless entity feature is enabled.
  def ensure_entity_page_enabled
    raise ActiveRecord::RecordNotFound unless Rails.application.config.x.enable.entity_page
  end

  def enforce_slug
    redirect_to url_for(slug: slug, format: params[:format]) unless params[:slug] == slug
  end

  def entity
    @entity ||= begin
      api_params = entities_api_fetch_params(api_type, api_namespace, params[:id])
      Europeana::API.entity.fetch(api_params)
    end
  end

  def slug
    @slug ||= Rails.cache.fetch(slug_cache_key) { entity_url_slug(entity) }
  end

  def slug_cache_key
    "entities/#{api_path}/slug"
  end

  def api_path
    @api_path ||= "#{api_type}/#{api_namespace}/#{params[:id]}"
  end

  def body_cache_key
    ['entities', params[:type], params[:id]].join('/')
  end

  def api_type
    @api_type ||= entities_api_type(params[:type])
  end

  def api_namespace
    'base'
  end

  def entity_params
    params.permit(:type, :id)
  end
end
