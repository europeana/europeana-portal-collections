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

    @items_by_query = build_query_items_by(params)

    respond_to do |format|
      format.html
      format.json { render json: @entity }
    end
  end

  # TODO
  def items_about
    render json: []
  end

  private

  # def build_query_items_by(params)
  #   url_suffix = params[:type] + '/' + params[:namespace] + '/' + params[:identifier]
  #   creator = 'proxy_dc_creator:"http://data.europeana.eu/' + url_suffix + '"'
  #   contributor = 'proxy_dc_contributor:"http://data.europeana.eu/' + url_suffix + '"'
  #   creator + ' OR ' + contributor
  # end

  def build_query_items_by(params)
    suffix = "#{params[:type]}/#{params[:namespace]}/#{params[:identifier]}"
    creator = build_proxy_dc('creator', "http://data.europeana.eu", suffix)
    contributor = build_proxy_dc('contributor', "http://data.europeana.eu", suffix)
    "#{creator} OR #{contributor}"
  end

  def build_proxy_dc(name, url, suffix)
    "proxy_dc_#{name}:\"#{url}/#{suffix}\""
  end
end
