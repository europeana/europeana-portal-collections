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

  def items_by
    # page=n || 0
    # per_page=n || 12
    query = build_query_items_by(params)
    search = Europeana::API.record.search(query: query, profile: 'portal')

    # {
    #      "title": "Glasgow School of Art - Exterior, Renfrew Street metalwork | Mackintosh, Charles Rennie",
    #      "is_image": true,
    #      "img": {
    #        "src": "/images/search/search-result-thumb-lincoln.jpg",
    #        "alt": "Rectangle"
    #      }
    # },

    # items = search.items.map{ |item| { title: item.title, is_image: item.is_image, img: { src: } } }

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
    creator + ' OR ' + contributor

  end
end
