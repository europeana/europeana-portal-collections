# frozen_string_literal: true
class EntitiesController < ApplicationController
  include Europeana::EntitiesApiConsumer
  before_action :get_entity, only: :show

  def suggest
    render json: Europeana::API.entity.suggest(entity_api_params(text: params[:text]))
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end

  protected

  def entity_api_params(query = {})
    query.merge(scope: 'europeana').tap do |api_params|
      api_params[:wskey] = ENV['EUROPEANA_ENTITIES_API_KEY'] if ENV['EUROPEANA_ENTITIES_API_KEY']
    end
  end

  private

  def get_entity
    api_fetch_params = entities_api_fetch_params(params[:type], params[:namespace], params[:identifier])
    @entity = Europeana::API.entity.fetch(api_fetch_params)
  end
end