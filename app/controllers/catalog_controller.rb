##
# Catalog controller using Blacklight for search and browse
class CatalogController < ApplicationController
  include Europeana::Catalog
  include Europeana::Styleguide

  def show
    @response, @document = fetch(doc_id)

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
