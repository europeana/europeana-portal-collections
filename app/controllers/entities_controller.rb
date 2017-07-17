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

  # here is an example of the search "from the Person":
  # https://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=proxy_dc_creator:"http://data.europeana.eu/agent/base/146741"+OR+proxy_dc_contributor:"http://data.europeana.eu/agent/base/146741"
  #
  # and the "template" is this one: https://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=proxy_dc_creator:"URI"+OR+proxy_dc_contributor:"URI"
  #
  # replace the URI with the URI of the person

  def items_by

    items = [
      {
        title: 'The Lighthouse, Glasgow (Glasgow Herald Building) - Exterior, stonework over entrance | Mackintosh, Charles Rennie',
        is_image: true,
        img: {
          src: '/images/search/search-result-thumb-1.jpg',
          alt: 'Rectangle'
        }
      },
      {
        title: 'Glasgow School of Art - Exterior, Renfrew Street metalwork | Mackintosh, Charles Rennie',
        is_image: true,
        img: {
          src: '/images/search/search-result-thumb-lincoln.jpg',
          alt: 'Rectangle'
        }
      }
    ]

    render json: {
      items: items,
      content_items_total_formatted: items.size,
      content_items_total: items.size,
    }
  end

  def items_about
    render json: []
  end
end
