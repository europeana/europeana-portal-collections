##
# Europeana portal controller
#
# The portal is an interface to the Europeana REST API, with search and
# browse functionality provided by {Blacklight}.
class PortalController < ApplicationController
  include Europeana::Catalog
  include Europeana::Styleguide

  before_filter :redirect_to_root, only: :index, unless: :has_search_parameters?

  # GET /search
  def index
    respond_to do |format|
      format.html { render 'templates/Search/Search-results-list' }
    end
  end

  # GET /record/:provider_id/:record_id
  def show
    @response, @document = fetch(doc_id)
    @similar = @document.more_like_this

    respond_to do |format|
      format.html do
        setup_next_and_previous_documents
        render template: 'templates/Search/Search-object'
      end
      format.json { render json: { response: { document: @document } } }
      additional_export_formats(@document, format)
    end
  end
end
