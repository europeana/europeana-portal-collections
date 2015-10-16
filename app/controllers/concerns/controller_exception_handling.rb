##
# Controller exception handling
#
# Error pages are kept in the CMS
#
# Disable CMS error pages to show Rails backtraces by setting the environment
# variable DISABLE_CMS_ERROR_PAGES (to any value)
module ControllerExceptionHandling
  extend ActiveSupport::Concern

  included do
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
        raise
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      handle_error(exception, 403)
    end

    rescue_from ActionController::UnknownFormat do |exception|
      handle_error(exception, 500, 'html')
    end
  end

  private

  def handle_error(exception, status, format = params[:format])
    log_error(exception)

    if ENV['DISABLE_CMS_ERROR_PAGES'] ||
        self.class.to_s.deconstantize == 'RailsAdmin'
      raise
    elsif format == 'json'
      render_json_error_response(exception, status)
    else
      render_html_error_response(exception, status)
    end
  end

  def log_error(exception)
    trace = Rails.backtrace_cleaner.clean(exception.backtrace)
    message = "\n#{exception.class} (#{exception.message}):\n"
    message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
    message << '  ' << trace.join("\n  ")
    logger.fatal("#{message}\n".red.bold)
  end

  def render_html_error_response(_exception, status)
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
