##
# Europeana portal controller
#
# The portal is an interface to the Europeana REST API, with search and
# browse functionality provided by {Blacklight}.
class PortalController < ApplicationController
  include Catalog
  include Europeana::Styleguide

  before_action :redirect_to_root, only: :index, unless: :has_search_parameters?

#   caches_action :index,
#     if: Proc.new { !request.format.json? },
#     expires_in: 1.day,
#     cache_path: Proc.new { cache_path_prefix + I18n.locale.to_s + request.original_fullpath }

#   caches_action :show,
#     if: Proc.new { !request.format.json? && !params.key?(:debug) },
#     expires_in: 1.day,
#     cache_path: Proc.new { cache_path_prefix + I18n.locale.to_s + request.original_fullpath }

  caches_action :static,
    expires_in: 1.hour,
    cache_path: Proc.new { cache_path_prefix + I18n.locale.to_s + request.original_fullpath }

  # GET /record/:id
  def show
    @response, @document = fetch(doc_id)
    @mlt_response, @similar = more_like_this(@document, nil, per_page: 4)
    @hierarchy = Europeana::API::Record::new('/' + params[:id]).hierarchy.ancestor_self_siblings
    @debug = JSON.pretty_generate(@document.as_json.merge(hierarchy: @hierarchy.as_json)) if params[:debug] == 'json'

    respond_to do |format|
      format.html do
        # setup_next_and_previous_documents
        render action: 'show'
      end
      format.json { render json: { response: { document: @document } } }
      additional_export_formats(@document, format)
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
    @page = params[:page] || 1
    @per_page = params[:per_page] || 4

    respond_to do |format|
      format.json { render :media, layout: false }
    end
  end

  # GET /record/:id/navigation
  def navigation
    @response, @document = fetch(doc_id)

    respond_to do |format|
      format.json do
        setup_next_and_previous_documents
        render :navigation, layout: false
      end
    end
  end

  # @todo move into own controller to isolate record resource related actions
  def static
    @page = Page.find_by_slug!(params[:page])
    authorize! :show, @page

    respond_to do |format|
      format.html do
        page_template = "pages/#{@page.slug}"
        render template_exists?(page_template) ? page_template : 'portal/static'
      end
    end
  end
end
