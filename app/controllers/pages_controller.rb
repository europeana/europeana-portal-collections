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
        page_template = "pages/custom/#{@page.slug}"
        template = template_exists?(page_template) ? page_template : 'pages/show'
        render template, status: @page.http_code
      end
    end
  end

  protected

  def find_page!
    @page = Page.find_by_slug!(params[:page])
  end
end
