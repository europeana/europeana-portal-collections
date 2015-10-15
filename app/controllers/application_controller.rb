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

  rescue_from StandardError do |exception|
    handle_error(exception, 500)
  end

  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError do |exception|
    handle_error(exception, 404)
  end

  rescue_from Europeana::API::Errors::RequestError do |exception|
    if exception.message.match(/Invalid record identifier/)
      handle_error(exception, 404)
    else
      rescue_action_without_handler(exception)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    handle_error(exception, 403)
  end

  rescue_from ActionController::UnknownFormat do |exception|
    handle_error(exception, 500, 'html')
  end

  private

  def log_error(exception)
    trace = Rails.backtrace_cleaner.clean(exception.backtrace)
    message = "\n#{exception.class} (#{exception.message}):\n"
    message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
    message << '  ' << trace.join("\n  ")
    logger.fatal("#{message}\n".red.bold)
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

  def handle_error(exception, status, format = params[:format])
    log_error(exception)

    if format == 'json'
      render_json_error_response(exception, status)
    else
      render_html_error_response(exception, status)
    end
  end

  def render_html_error_response(exception, status)
    @page = Page::Error.find_by_http_code!(status)
    page_template = "pages/#{@page.slug}"
    template = template_exists?(page_template) ? page_template : 'portal/static'
    render template, status: status
  end

  def render_json_error_response(exception, status)
    msg = Rack::Utils::HTTP_STATUS_CODES[status]
    msg << ": #{exception.message}" unless exception.message.blank?
    render json: { success: false, error: msg }, status: status
  end
end
