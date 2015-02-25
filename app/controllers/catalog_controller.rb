##
# Catalog controller using Blacklight for search and browse
class CatalogController < ApplicationController
  include EuropeanaCatalog

  before_filter :retrieve_response_and_document, only: :show

  def show
    respond_to do |format|
      format.html { setup_next_and_previous_documents }

      format.json { render json: { response: { document: @document } } }

      # Add all dynamically added (such as by document extensions)
      # export formats.
      @document.export_formats.each_key do |format_name|
        # It's important that the argument to send be a symbol;
        # if it's a string, it makes Rails unhappy for unclear reasons.
        format.send(format_name.to_sym) do
          render text: @document.export_as(format_name), layout: false
        end
      end
    end
  end

  protected

  def retrieve_response_and_document
    @response, @document = get_solr_response_for_doc_id doc_id
    @document.load_hierarchy
  end

  def doc_id
    @doc_id ||= [params[:provider_id], params[:record_id]].join('/')
  end
end
