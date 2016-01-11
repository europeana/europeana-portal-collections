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
  include CollectionsHelper

  included do
    skip_before_filter :verify_authenticity_token
  end

  def doc_id
    @doc_id ||= '/' + params[:id]
  end

  def more_like_this(document, field = nil, extra_controller_params = {})
    mlt_params = params.dup.slice(:page, :per_page)
    mlt_params.merge!(mlt: document, mltf: field)
    mlt_params.merge!(extra_controller_params)
    search_results(mlt_params, search_params_logic)
  rescue Net::HTTPBadResponse, Europeana::API::Errors::RequestError,
         Europeana::API::Errors::ResponseError
    # For records with many terms in MLT fields, the MLT queries can result in
    # *very* large API URLs, which cause a variety of request/response errors
    [nil, []]
  end

  def search_results(user_params, search_params_logic)
    response, documents = super
    response.max_pages_per(960 / response.limit_value)
    [response, documents]
  end

  # Overrides {Blacklight::SearchHelper} method to detect Collections searches
  def get_previous_and_next_documents_for_search(index, request_params, extra_controller_params = {})
    p = previous_and_next_document_params(index)

    builder = if within_collection?(request_params)
                search_builder.with_overlay_params(current_search_collection.api_params_hash)
              else
                search_builder
              end

    query = builder.with(request_params).start(p.delete(:start)).rows(p.delete(:rows)).merge(extra_controller_params).merge(p)
    response = repository.search(query)

    document_list = response.documents

    # only get the previous doc if there is one
    prev_doc = document_list.first if index > 0
    next_doc = document_list.last if (index + 1) < response.total

    [response, [prev_doc, next_doc]]
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
