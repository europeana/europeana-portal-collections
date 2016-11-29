##
# Europeana portal controller
#
# The portal is an interface to the Europeana REST API, with search and
# browse functionality provided by {Blacklight}.
class PortalController < ApplicationController
  include Europeana::AnnotationsApiConsumer
  include Europeana::UrlConversions
  include OembedRetriever

  before_action :redirect_to_home, only: :index, unless: :has_search_parameters?
  before_action :log_search_interaction, only: :show, if: :has_loggable_parameters?

  def redirect_to_home
    redirect_to home_path
  end

  attr_reader :url_conversions, :oembed_html

  rescue_from URI::InvalidURIError do |exception|
    handle_error(exception: exception, status: 404, format: 'html')
  end

  # GET /search
  def index
    @landing_page = find_landing_page
    (@response, @document_list) = search_results(params)
    respond_to do |format|
      format.html { store_preferred_view }
    end
  end

  # GET /record/:id
  def show
    @response, @document = fetch(doc_id, api_query_params)
    @url_conversions = perform_url_conversions(@document)
    @oembed_html = oembed_for_urls(@document, @url_conversions)

    @mlt_response, @similar = more_like_this(@document, nil, per_page: 4)
    @hierarchy = document_hierarchy(@document)
    @annotations = document_annotations(@document)

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

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: '').tap do |landing_page|
      authorize! :show, landing_page
    end
  end

  def log_search_interaction
    Rails.logger.info(search_interaction_msg.chomp) if referer_was_search_request?

    redirect_to url_for(params.except(:l))
  end

  def search_interaction_msg
    <<~EOS
      Search interaction:
      * Record: /#{params[:id]}
      * Search parameters: #{params[:l][:p].inspect}
      * Total hits: #{params[:l][:t]}
      * Result rank: #{params[:l][:r]}
    EOS
  end

  def referer_was_search_request?
    referer = request.referer
    return false unless referer.present?

    search_urls = [search_url] + displayable_collections.map { |c| collection_url(c) }
    search_urls.any? { |u| referer.match "^#{u}(\\?|$)" }
  end

  def document_hierarchy(document)
    return nil unless document.fetch('proxies.dctermsIsPartOf', nil).present? || document.fetch('proxies.dctermsHasPart', nil).present?
    Europeana::API.record.ancestor_self_siblings(api_query_params.merge(id: document.id))
  rescue Europeana::API::Errors::ResourceNotFoundError
    nil
  end

  def has_loggable_parameters?
    params.key?(:l)
  end

  def api_query_params
    params.slice(:api_url)
  end
end
