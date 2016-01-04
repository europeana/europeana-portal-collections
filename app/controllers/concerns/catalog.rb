require 'net/http'

##
# Include this concern in a controller to give it Blacklight catalog features
# with extensions specific to Europeana.
#
# @todo Does any of this belong in {Europeana::Blacklight}?
module Catalog
  extend ActiveSupport::Concern

  include ::Blacklight::Base
  include Europeana::Blacklight::Catalog
  include BlacklightConfig
  include ActiveSupport::Benchmarkable

  def doc_id
    @doc_id ||= '/' + params[:id]
  end

  def more_like_this(document, field = nil, extra_controller_params = {})
    mlt_params = params.dup.slice(:page, :per_page)
    mlt_params.merge!(mlt: document, mltf: field)
    mlt_params.merge!(extra_controller_params)
    search_results(mlt_params, search_params_logic)
  rescue Net::HTTPBadResponse, Europeana::API::Errors::RequestError
    # For records with many terms in MLT fields, the MLT queries can result in
    # *very* large API URLs, which cause a variety of request/response errors
    [nil, []]
  end

  def search_results(user_params, search_params_logic)
    response, documents = super
    response.max_pages_per(960 / response.limit_value)
    [response, documents]
  end

  protected

  def search_action_url(options = {})
    case
    when options[:controller]
      url_for(options)
    when params[:controller] == 'collections'
      url_for(options.merge(controller: 'collections', action: params[:action]))
    else
      search_url(options.except(:controller, :action))
    end
  end

  def search_facet_url(options = {})
    facet_url_params = { controller: 'portal', action: 'facet' }
    url_for params.merge(facet_url_params).merge(options).except(:page)
  end
end
