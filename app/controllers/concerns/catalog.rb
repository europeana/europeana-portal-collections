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
  include CollectionsHelper

  included do
    skip_before_action :verify_authenticity_token
  end

  def doc_id
    @doc_id ||= '/' + params[:id]
  end

  def more_like_this(document, field = nil, extra_controller_params = {})
    mlt_params = params.dup.slice(:page, :per_page)
    mlt_params.merge!(mlt: document, mltf: field)
    mlt_params.merge!(extra_controller_params)
    search_results(mlt_params)
  rescue Net::HTTPBadResponse, Europeana::API::Errors::RequestError,
         Europeana::API::Errors::ResponseError
    # For records with many terms in MLT fields, the MLT queries can result in
    # *very* large API URLs, which cause a variety of request/response errors
    [nil, []]
  end

  def search_results(user_params)
    response, documents = super
    response.max_pages_per(960 / response.limit_value)
    add_collection_facet(response)
    [response, documents]
  end

  ##
  # Override {Blacklight::SearchContext#find_or_initialize_search_session_from_params}
  # to prevent searches from being logged.
  def find_or_initialize_search_session_from_params(_params)
  end

  # Overrides {Blacklight::SearchHelper} method to detect Collections searches
  def get_previous_and_next_documents_for_search(*_args)
    fail "Do not Blacklight's search tracking."
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

  def add_collection_facet(response)
    items = displayable_collections.map do |collection|
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: collection.key)
    end
    items.unshift(Europeana::Blacklight::Response::Facets::FacetItem.new(value: 'all'))
    field = Europeana::Blacklight::Response::Facets::FacetField.new('COLLECTION', items)
    response.aggregations[field.name] = field
  end
end
