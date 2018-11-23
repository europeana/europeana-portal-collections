# frozen_string_literal: true

##
# Europeana portal controller
#
# The portal is an interface to the Europeana REST API, with search and
# browse functionality provided by {Blacklight}.
class PortalController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include Europeana::URIMappers
  include Europeana::SearchAPIConsumer
  include GalleryHelper
  include NewsHelper
  include OembedRetriever
  include ParentRecordHelper
  include SearchInteractionLogging
  include ThumbnailHelper

  before_action :redirect_to_home, only: :index, unless: :has_search_parameters?
  before_action :log_search_interaction_on_show, only: :show

  attr_reader :url_conversions, :oembed_html, :media_headers

  rescue_from URI::InvalidURIError do |exception|
    handle_error(exception: exception, status: 404, format: 'html')
  end

  # GET /search
  def index
    @landing_page = find_landing_page
    @collection = Collection.find_by_key('all')
    (@response, @document_list) = search_results(params)

    log_search_interaction_on_search(@response)

    respond_to do |format|
      format.html
      format.json { render layout: false }
    end
  end

  # GET /record/:id
  def show
    @response, @document = fetch(doc_id, api_query_params)

    if document_is_europeana_ancestor?
      show_ancestor
    else
      show_generic
    end

    @debug = JSON.pretty_generate(@document.as_json) if params[:debug] == 'json'

    respond_to do |format|
      format.html { render @template || 'portal/show' }
      format.json { render json: { response: { document: @document } } }
    end
  end

  # GET /record/:id/similar
  def similar
    mlt_query = params[:mlt_query] || fetch(doc_id)[1].more_like_this_query
    extra_controller_params = params.slice(:per_page, :page, :api_url).reverse_merge(per_page: 4)
    @response, @similar = more_like_this(mlt_query, extra_controller_params)
    respond_to do |format|
      format.json { render :similar, layout: false }
    end
  end

  # GET /record/:id/media
  def media
    @response, @document = fetch(doc_id)
    @url_conversions = perform_url_conversions(@document)
    @media_headers = perform_media_header_requests(@document)
    @oembed_html = oembed_for_urls(@document, @url_conversions)
    @page = params[:page] || 1
    @per_page = params[:per_page] || 4

    respond_to do |format|
      format.json { render :media, layout: false }
    end
  end

  # GET /record/:id/annotations
  def annotations
    @annotations = document_annotations(doc_id)

    respond_to do |format|
      format.json { render :annotations, layout: false }
    end
  end

  # GET /record/:id/gallery
  def gallery
    gallery = Gallery.published.joins(:images).where(gallery_images: { europeana_record_id: doc_id }).
              order(published_at: :desc).first
    @resource = gallery_promo_content(gallery)
    respond_to do |format|
      format.json { render :promo_card, layout: false }
    end
  end

  def parent
    # Search the API for the record with dcterms:hasPart data.europeana.eu/item/RECORD_ID
    @resource = parent_promo_content(search_results_for_dcterms_has_part(doc_id, rows: 1)[:items]&.first)

    respond_to do |format|
      format.json { render :promo_card, layout: false }
    end
  end

  def news
    # Get a post featuring this record from Pro's JSON API
    post = Pro::Post.with_params(contains: { image_attribution_link: doc_id }).
           order(datepublish: :desc).per(1).first

    @resource = news_promo_content(post)
    respond_to do |format|
      format.json { render :promo_card, layout: false }
    end
  end

  protected

  def show_generic
    # TODO: remove when new design is default
    @new_design = Rails.application.config.x.enable.new_record_page_design ? params[:design] != 'old' : params[:design] == 'new'

    @data_provider = document_data_provider(@document)
    @url_conversions = perform_url_conversions(@document)
    @media_headers = perform_media_header_requests(@document)
    @oembed_html = oembed_for_urls(@document, @url_conversions)
    @mlt_query = @document.more_like_this_query
  end

  def show_ancestor
    @search_results = search_results_for_dcterms_is_part_of(@document.id)
    @template = 'portal/ancestor'
  end

  def document_annotations(id)
    Europeana::Record.new(id).annotations
  rescue Europeana::API::Errors::ServerError, Europeana::API::Errors::ResponseError => error
    # TODO: we may not want controller actions to fail if annotations are
    #   unavailable, but we should return something indicating that there
    #   was a failure and perhaps indicate it to the user, e.g. as
    #   "Annotations could not be retrieved".
    logger.error(error.message)
    nil
  end

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

  def redirect_to_home
    redirect_to home_path
  end

  # Is the document the ancestor of other Europeana records?
  #
  # Criteria:
  # * +Europeana::Record::Hierarchies.europeana_ancestor?+ returns true for proxy's dcterms:hasPart
  #
  # @return [Boolean]
  def document_is_europeana_ancestor?
    dcterms_has_part = @document.fetch('proxies.dctermsHasPart', []).compact
    Europeana::Record::Hierarchies.europeana_ancestor?(dcterms_has_part)
  end
end
