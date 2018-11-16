# frozen_string_literal: true

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

  def more_like_this(mlt_query, extra_controller_params = {})
    mlt_params = extra_controller_params.merge(q: mlt_query)
    search_results(mlt_params)
  rescue Net::HTTPBadResponse, Europeana::API::Errors::RequestError,
         Europeana::API::Errors::ResponseError
    # For records with many terms in MLT fields, the MLT queries can result in
    # *very* large API URLs, which cause a variety of request/response errors
    [nil, []]
  end

  def search_results(user_params)
    response, documents = super
    response.max_pages(960 / response.limit_value)
    inject_pseudo_facets(response)
    [response, documents]
  end

  ##
  # Override {Blacklight::SearchContext#find_or_initialize_search_session_from_params}
  # to prevent searches from being logged.
  def find_or_initialize_search_session_from_params(_params); end

  # Overrides {Blacklight::SearchHelper} method to detect Collections searches
  def get_previous_and_next_documents_for_search(*_args)
    fail "Do not use Blacklight's search tracking."
  end

  def search_action_path(options = {})
    options[:only_path] = true
    search_action_url(options)
  end

  def search_action_url(options = {})
    if options[:controller]
      url_for(options.except(:page))
    elsif params[:controller] == 'collections'
      url_for(options.merge(controller: 'collections', action: params[:action]))
    else
      search_url(options.except(:controller, :action))
    end
  end

  def has_search_parameters?
    super || params.key?(:qe)
  end

  protected

  def search_facet_url(options = {})
    facet_url_params = { controller: 'portal', action: 'facet' }
    url_for params.merge(facet_url_params).merge(options).except(:page)
  end

  def inject_pseudo_facets(response)
    pseudo_facets = blacklight_config.facet_fields.values.select { |ff| !ff.include_in_request && ff.values.present? }
    pseudo_facets.each do |ff|
      values = ff.values.respond_to?(:call) ? ff.values.call(self) : ff.values
      items = values.map { |value| Europeana::Blacklight::Response::Facets::FacetItem.new(value: value) }
      field = Europeana::Blacklight::Response::Facets::FacetField.new(ff.key, items)
      response.aggregations[field.name] = field
    end
  end
end
