# frozen_string_literal: true
class EntitiesController < ApplicationController
  def suggest
    render json: Europeana::API.entity.suggest(entity_api_params(text: params[:text]))
  end

  protected

  def entity_api_params(query = {})
    query.merge(scope: 'europeana').tap do |api_params|
      api_params[:wskey] = ENV['EUROPEANA_ENTITIES_API_KEY'] if ENV['EUROPEANA_ENTITIES_API_KEY']
    end
  end
end