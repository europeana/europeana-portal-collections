# frozen_string_literal: true

##
# Static pages controller
class PagesController < ApplicationController
  # needs to occur before `include EnforceDefaultFormat`
  # to catch 404 errors first, and not redirect them to .html extension
  before_action :find_page!

  include EnforceDefaultFormat

  def show
    authorize! :show, @page

    respond_to do |format|
      format.html do
        render template_for_page, status: @page.http_code
      end
    end
  end

  protected

  def find_page!
    @page = Page.find_by_slug!(params[:page])
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
      'pages/browse'
    else
      'pages/show'
    end
  end

  def custom_page_template
    @custom_page_template ||= "pages/custom/#{@page.slug}"
  end
end
