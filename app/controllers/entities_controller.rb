# frozen_string_literal: true
class EntitiesController < ApplicationController
  include Europeana::EntitiesApiConsumer

  def suggest
    render json: Europeana::API.entity.suggest(entities_api_suggest_params(params[:text]))
  end

  def show
    @entity = Europeana::API.
              entity.fetch(entities_api_fetch_params(params[:type], params[:namespace], params[:identifier])).
              merge(__params__: { type: params[:type], namespace: params[:namespace], identifier: params[:identifier] })

    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end

  def items_by
    query = build_query_items_by(params)
    search = Europeana::API.record.search(query: query)

    render json: {
      items: search[:items],
      content_items_total_formatted: search[:totalResults],
      content_items_total: search[:totalResults]
    }
  end

  def items_about
    render json: []
  end

  private

  def build_query_items_by(params)
    url_suffix = params[:type] + '/' + params[:namespace] + '/' + params[:identifier]
    creator = 'proxy_dc_creator:"http://data.europeana.eu/' + url_suffix + '"'
    contributor = 'proxy_dc_contributor:"http://data.europeana.eu/' + url_suffix + '"'
    creator + '+OR+' + contributor
  end
end
