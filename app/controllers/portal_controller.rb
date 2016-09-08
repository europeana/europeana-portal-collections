##
# Europeana portal controller
#
# The portal is an interface to the Europeana REST API, with search and
# browse functionality provided by {Blacklight}.
class PortalController < ApplicationController
  include Europeana::UrlConversions
  include OembedRetriever

  before_action :redirect_to_home, only: :index, unless: :has_search_parameters?

  def redirect_to_home
    redirect_to home_path
  end

  attr_reader :url_conversions, :oembed_html

  rescue_from URI::InvalidURIError do |exception|
    handle_error(exception, 404, 'html')
  end

  # GET /search
  def index
    (@response, @document_list) = search_results(params)
    respond_to do |format|
      format.html { store_preferred_view }
    end
  end

  # GET /record/:id
  def show
    @response, @document = fetch(doc_id)
    @url_conversions = perform_url_conversions(@document)
    @oembed_html = oembed_for_urls(@document, @url_conversions)

    @mlt_response, @similar = more_like_this(@document, nil, per_page: 4)
    @hierarchy = document_hierarchy(@document)
    @debug = JSON.pretty_generate(@document.as_json.merge(hierarchy: @hierarchy.as_json)) if params[:debug] == 'json'

    respond_to do |format|
      format.html
      format.json { render json: { response: { document: @document } } }
    end
  end

  # GET /record/:id/similar
  def similar
    _response, document = fetch(doc_id)
    @response, @similar = more_like_this(document, params[:mltf], per_page: params[:per_page] || 4)
    respond_to do |format|
      format.json { render :similar, layout: false }
    end
  end

  # GET /record/:id/media
  def media
    @response, @document = fetch(doc_id)
    @url_conversions = perform_url_conversions(@document)
    @oembed_html = oembed_for_urls(@document, @url_conversions)
    @page = params[:page] || 1
    @per_page = params[:per_page] || 4

    respond_to do |format|
      format.json { render :media, layout: false }
    end
  end

  protected

  def document_hierarchy(document)
    return nil unless document.fetch('proxies.dctermsIsPartOf', nil).present? || document.fetch('proxies.dctermsHasPart', nil).present?
    Europeana::API::Record.new(document.id).hierarchy.ancestor_self_siblings
  end
end
