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

    rescue_from Europeana::API::Errors::Request::PaginationError do |exception|
      handle_error(exception, 400)
    end

    rescue_from Europeana::API::Errors::RequestError do |exception|
      case exception.message
      when /Invalid record identifier/
        handle_error(exception, 404)
      else
        handle_error(exception, 400)
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      handle_error(exception, 403)
    end

    rescue_from ActionController::UnknownFormat do |exception|
      handle_error(exception, 404, 'html')
    end
  end

  private

  def handle_error(exception, status, format = params[:format])
    status = 500 if self.class.to_s.deconstantize == 'RailsAdmin' && status != 403

    log_error(exception)
    report_error(exception) if status == 500

    if ENV['DISABLE_CMS_ERROR_PAGES']
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
    logger.error("#{message}\n".red.bold)
  end

  def report_error(exception)
    return unless Rails.application.config.x.error_report_mail_to.present? # No email recipient configured

    ErrorMailer.report(
      { class: exception.class.to_s, message: exception.message, backtrace: exception.backtrace },
      { original_url: request.original_url, method: request.method, referer: request.referer }
    ).deliver_later
  end

  def render_html_error_response(exception, status)
    @page = Page::Error.for_exception(exception, status)
    @page ||= Page::Error.generic.find_by_http_code!(status)

    if self.class.to_s.deconstantize == 'RailsAdmin'
      redirect_to [Rails.configuration.relative_url_root, @page.slug].join('/')
    else
      page_template = "pages/custom/#{@page.slug}"
      template = template_exists?(page_template) ? page_template : 'pages/show'
      render template, status: @page.http_code, formats: [:html]
    end
  end

  def render_json_error_response(exception, status)
    msg = Rack::Utils::HTTP_STATUS_CODES[status]
    msg << ": #{exception.message}" unless exception.message.blank?
    render json: { success: false, error: msg }, status: status
  end
end
