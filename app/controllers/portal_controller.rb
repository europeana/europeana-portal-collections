##
# Europeana portal controller
#
# The portal is an interface to the Europeana REST API, with search and
# browse functionality provided by {Blacklight}.
class PortalController < ApplicationController
  include Europeana::AnnotationsApiConsumer
  include Europeana::UrlConversions
  include OembedRetriever
  include SearchInteractionLogging
  include ActionView::Helpers::NumberHelper

  before_action :redirect_to_home, only: :index, unless: :has_search_parameters?
  before_action :log_show_search_interaction, only: :show

  attr_reader :url_conversions, :oembed_html

  rescue_from URI::InvalidURIError do |exception|
    handle_error(exception: exception, status: 404, format: 'html')
  end

  # GET /search
  def index
    @landing_page = find_landing_page
    @collection = Collection.find_by_key('all')
    (@response, @document_list) = search_results(params)

    log_search_interaction(
      search: params.slice(:q, :f, :mlt, :range).inspect,
      total: @response.total
    )

    respond_to do |format|
      format.html
      format.json do
        render json: {
          search_results: @document_list.map do |doc|
            Document::SearchResultPresenter.new(doc, self, @response).content
          end,
          total: {
            value: @response.total,
            formatted: number_with_delimiter(@response.total)
          }
        }
      end
    end
  end

  # GET /record/:id
  def show
    @response, @document = fetch(doc_id, api_query_params)
    @data_provider = document_data_provider(@document)

    @url_conversions = perform_url_conversions(@document)
    @oembed_html = oembed_for_urls(@document, @url_conversions)
    @annotations = document_annotations(@document)
    @about = document_about(@document)

    @debug = JSON.pretty_generate(@document.as_json) if params[:debug] == 'json'

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

  def document_data_provider(document)
    data_provider_name = document.fetch('aggregations.edmDataProvider', []).first
    DataProvider.find_by_name(data_provider_name)
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: '').tap do |landing_page|
      authorize! :show, landing_page
    end
  end

  def api_query_params
    params.slice(:api_url)
  end

  def log_show_search_interaction
    return unless referer_was_search_request? && params.key?(:l)
    log_search_interaction(
      record: params[:id],
      search: params[:l][:p].inspect,
      total: params[:l][:t],
      rank: params[:l][:r]
    )
    redirect_to url_for(params.except(:l))
  end

  def redirect_to_home
    redirect_to home_path
  end
end
