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
      handle_error(exception: exception, status: 500)
    end

    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError do |exception|
      handle_error(exception: exception, status: 404)
    end

    rescue_from Europeana::API::Errors::Request::PaginationError do |exception|
      handle_error(exception: exception, status: 400)
    end

    rescue_from Europeana::API::Errors::RequestError do |exception|
      case exception.message
      when /Invalid record identifier/
        handle_error(exception: exception, status: 404)
      else
        handle_error(exception: exception, status: 400)
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      handle_error(exception: exception, status: 403)
    end

    rescue_from ActionController::UnknownFormat do |exception|
      handle_error(exception: exception, status: 404, format: 'html')
    end
  end

  module ErrorHandlers
    ##
    # Writes the stacktrace to the Rails log
    #
    # Disable by setting the env var `DISABLE_ERROR_LOGGING`
    class Logger
      class << self
        def enabled?
          !ENV['DISABLE_ERROR_LOGGING']
        end

        def process(exception:, **_)
          Rails.logger.error(message(exception: exception).red.bold)
        end

        def message(exception:)
          message = "\n#{exception.class} (#{exception.message}):\n"
          message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
          message << '  ' << trace(exception: exception).join("\n  ")
        end

        def trace(exception:)
          Rails.backtrace_cleaner.clean(exception.backtrace)
        end
      end
    end

    ##
    # Emails a summary of the error
    #
    # Recipient is set in the env var `ERROR_REPORT_MAIL_TO`. If this is not
    # set, this handler will be disabled.
    class EmailReporter
      class << self
        ##
        # Requires email recipient to be configured
        def enabled?
          Rails.application.config.x.error_report_mail_to.present?
        end

        def process(exception:, request:, status:, **_)
          return if status == 500

          ErrorMailer.report_http(
            exception: { class: exception.class.to_s, message: exception.message, backtrace: exception.backtrace },
            request: { original_url: request.original_url, method: request.method, referer: request.referer }
          ).deliver_later
        end
      end
    end

    ##
    # Notifies New Relic of the error
    #
    # New Relic notices unhandled exceptions by default, but not handled ones
    # unless we explicitly notify it.
    #
    # Depends on existent configuration of New Relic Ruby Agent. See
    # <https://docs.newrelic.com/docs/agents/ruby-agent>
    class NewRelicNotifier
      class << self
        def enabled?
          defined?(NewRelic) && NewRelic::Agent.instance.started?
        end

        def process(exception:, request:, **_)
          NewRelic::Agent.notice_error(exception,
                                       uri: request.original_url, referer: request.referer)
        end
      end
    end
  end

  ERROR_HANDLERS = [ErrorHandlers::Logger, ErrorHandlers::EmailReporter, ErrorHandlers::NewRelicNotifier].freeze

  private

  ##
  # Runs an exception through all of the registered handler classes, then
  # renders an error response
  def handle_error(exception:, status:, format: params[:format])
    status = 500 if failed_in_cms_request? && status != 403

    ERROR_HANDLERS.select(&:enabled?).each do |handler|
      handler.process(exception: exception, status: status, format: format, request: request)
    end

    render_error_response(exception: exception, status: status, format: format)
  end

  ##
  # Render an error response
  #
  # If the env var `DISABLE_CMS_ERROR_PAGES` is set, the exception will be
  # raised, output using Rails default exception display, useful during
  # development.
  def render_error_response(exception:, status:, format:)
    if ENV['DISABLE_CMS_ERROR_PAGES']
      raise
    elsif format == 'json'
      render_json_error_response(exception: exception, status: status)
    else
      render_html_error_response(exception: exception, status: status)
    end
  end

  ##
  # Render an HTML error page from the CMS
  def render_html_error_response(exception:, status:)
    @page = page_for_html_error_response(exception: exception, status: status)

    if failed_in_cms_request?
      # RailsAdmin does not have access to the styleguide templates, so
      # redirect to the absolute path of the error page.
      redirect_to [Rails.configuration.relative_url_root, @page.slug].join('/')
    else
      render template_for_html_error_response_page(page: @page), status: @page.http_code, formats: [:html]
    end
  end

  def page_for_html_error_response(exception:, status:)
    Page::Error.for_exception(exception, status) || Page::Error.generic.find_by_http_code!(status)
  end

  def template_for_html_error_response_page(page:)
    page_template = "pages/custom/#{page.slug}"
    template_exists?(page_template) ? page_template : 'pages/show'
  end

  ##
  # Render a simple JSON error response
  def render_json_error_response(exception:, status:)
    msg = Rack::Utils::HTTP_STATUS_CODES[status]
    msg << ": #{exception.message}" unless exception.message.blank?
    render json: { success: false, error: msg }, status: status
  end

  ##
  # Did the error occur while using the RailsAdmin CMS?
  def failed_in_cms_request?
    request_in_cms?
  end
end
