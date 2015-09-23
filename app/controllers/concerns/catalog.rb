require 'net/http'

##
# Include this concern in a controller to give it Blacklight catalog features
# with extensions specific to Europeana.
#
# @todo Break up into sub-modules
# @todo Does any of this belong in {Europeana::Blacklight}?
module Catalog
  extend ActiveSupport::Concern

  include ::Blacklight::Base
  include Europeana::Blacklight::Catalog
  include BlacklightConfig
  include ActiveSupport::Benchmarkable

  included do
    # Adds Blacklight nav action for Channels
    # @todo move to europeana-blacklight gem; not used by europeana-styleguide
    #   mustache templates
    # add_nav_action(:channels, partial: 'channels/nav')
  end

  def doc_id
    @doc_id ||= '/' + params[:id]
  end

  def fetch_with_hierarchy(id = nil, extra_controller_params = {})
    response, _document = fetch(id, extra_controller_params)
    hierarchy = repository.fetch_document_hierarchy(id)
    response.documents.first.hierarchy = hierarchy
    [response, response.documents.first]
  end

  def more_like_this(document, field = nil, extra_controller_params = {})
    mlt_params = params.dup.slice(:page, :per_page)
    mlt_params.merge!(mlt: document.id, mltf: field)
    mlt_params.merge!(extra_controller_params)
    search_results(mlt_params, search_params_logic)
  end

  def media_mime_type(document)
    edm_is_shown_by = document.fetch('aggregations.edmIsShownBy', []).first
    return nil if edm_is_shown_by.nil?

    cache_key = "Europeana/MediaProxy/Response/#{edm_is_shown_by}"
    response = Rails.cache.fetch(cache_key)
    if response.nil?
      response = remote_content_type_header(document)
      Rails.cache.write(cache_key, response)
    end

    if [Net::HTTPClientError, Net::HTTPServerError].include?(response.class.superclass)
      nil
    else
      response['content-type']
    end
  end

  protected

  def remote_content_type_header(document)
    url = URI(Rails.application.config.x.edm_is_shown_by_proxy + document.id)
    benchmark("[Media Proxy] #{url}", level: :info) do
      Net::HTTP.start(url.host, url.port) do |http|
        http.head(url.path)
      end
    end
  end

  def search_action_url(options = {})
    case
    when options[:controller]
      url_for(options)
    when params[:controller] == 'channels'
      url_for(options.merge(controller: 'channels', action: params[:action]))
    else
      search_url(options.except(:controller, :action))
    end
  end

  def search_facet_url(options = {})
    facet_url_params = { controller: 'portal', action: 'facet' }
    url_for params.merge(facet_url_params).merge(options).except(:page)
  end

  ##
  # Gets the total number of items available over the Europeana API
  #
  # @return [Fixnum]
  def count_all
    all_params = { query: '*:*', rows: 0, profile: 'minimal' }
    @europeana_item_count = repository.search(all_params).total
  end
end
