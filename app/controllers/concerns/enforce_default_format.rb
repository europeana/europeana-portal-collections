# frozen_string_literal: true

##
# Controller methods for redirecting to HTML format if none specified
#
# Include this in a controller so that requests for paths without a format
# extension are redirected to the same with .html appended.
module EnforceDefaultFormat
  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_html_extension
  end

  protected

  def redirect_to_html_extension
    return unless params[:format].blank?
    redirect_to url_for(params.merge(format: 'html'))
  end
end
