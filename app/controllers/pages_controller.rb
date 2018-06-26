# frozen_string_literal: true

##
# Static pages controller
class PagesController < ApplicationController
  # needs to occur before `include EnforceDefaultFormat`
  # to catch 404 errors first, and not redirect them to .html extension
  before_action :find_page!

  include CacheHelper
  include EnforceDefaultFormat

  attr_reader :body_cache_key

  def show
    authorize! :show, @page

    @body_cache_key = @page.cache_key

    populate_content_for_page

    respond_to do |format|
      format.html do
        render template_for_page, status: @page.http_code
      end
    end
  end

  protected

  def find_page!
    @page = Page.includes(:elements).find_by_slug!(params[:page])
  end

  # Populates instance variables for the page based on its type
  def populate_content_for_page
    return if body_cached?
    if @page.is_a?(Page::Browse::RecordSets)
      @documents = search_api_for_record_metadata.each_with_object({}) do |document, memo|
        memo[document.id] = document
      end
    end
  end

  # Ascertain which template to render for the requested page
  #
  # 1. If a custom page template exists named `"pages/custom/#{page.slug}"`, use it
  # 2. If the page type is +Page::Browse::RecordSets+, use pages/browse
  # 3. Otherwise, use pages/show
  #
  # @return [String] template path
  def template_for_page
    if template_exists?(custom_page_template)
      custom_page_template
    elsif @page.is_a?(Page::Browse::RecordSets)
      'pages/browse/record_sets'
    else
      'pages/show'
    end
  end

  def custom_page_template
    @custom_page_template ||= "pages/custom/#{@page.slug}"
  end

  # @return [Array<Europeana::Blacklight::Document>]
  # TODO: skip facets and use minimal profile
  # TODO: make multiple requests when IDs > 100
  def search_api_for_record_metadata
    search_results(blacklight_api_params_for_records).last
  end

  def blacklight_api_params_for_records
    { q: @page.search_api_query_for_records, per_page: 100 }
  end
end
