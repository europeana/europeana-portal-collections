# frozen_string_literal: true
class EntitiesController < ApplicationController
  include Europeana::Entities
  include Europeana::EntitiesApiConsumer

  def suggest
    render json: Europeana::API.entity.suggest(entities_api_suggest_params(params[:text]))
  end

  def show
    @entity = Europeana::API.
              entity.fetch(entities_api_fetch_params(params[:type], params[:namespace], params[:identifier]))

    @items_by_query = build_query_items_by(params)

    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end
end
