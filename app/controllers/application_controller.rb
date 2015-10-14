##
# Main application controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  layout proc { kind_of?(Europeana::Styleguide) ? false : 'application' }

  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError do
    render_error_page(404)
  end

  def set_locale
    session[:locale] ||= I18n.default_locale
    I18n.locale = session[:locale]
  end

  def redirect_to_root
    redirect_to root_url
    return false
  end

  def current_user
    super || User.new(guest: true)
  end

  private

  def render_error_page(status)
    @page = Page::Error.find_by_http_code!(status)
    page_template = "pages/#{@page.slug}"
    template = template_exists?(page_template) ? page_template : 'pages/static'
    render template, status: status
  end
end
