##
# Static pages controller
class PagesController < ApplicationController
  def show
    @page = Page.find_by_slug!(params[:page])
    authorize! :show, @page

    respond_to do |format|
      format.html do
        page_template = "pages/custom/#{@page.slug}"
        template = template_exists?(page_template) ? page_template : 'pages/show'
        render template, status: @page.http_code
      end
    end
  end
end
