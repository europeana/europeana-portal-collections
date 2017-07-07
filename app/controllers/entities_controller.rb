# frozen_string_literal: true
class EntitiesController < ApplicationController
  include Europeana::EntitiesApiConsumer

  def suggest
    render json: Europeana::API.entity.suggest(entities_api_suggest_params(params[:text]))
  end

  def fetch
    render json: Europeana::API.entity.fetch(entities_api_fetch_params(params[:type], params[:namespace], params[:identifier]))
  end
end