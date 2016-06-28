##
# Main application controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include ControllerExceptionHandling
  include Europeana::Styleguide
  include Catalog

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  layout proc { kind_of?(Europeana::Styleguide) ? false : 'application' }

  def localise
    relative_url_root = Europeana::Portal::Application.config.relative_url_root
    dest = if relative_url_root.present?
             request.original_fullpath.sub(/\A#{relative_url_root}/, "#{relative_url_root}/#{I18n.locale}")
           elsif request.original_fullpath == '/'
             "/#{I18n.locale}"
           else
             "/#{I18n.locale}#{request.original_fullpath}"
           end

    redirect_to dest
  end

  def current_user
    super || User.new(guest: true)
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options).tap do |url_options|
      if ENV['HTTP_HOST']
        url_options.merge!(host: ENV['HTTP_HOST'] )
      end
    end
  end

  private

  def set_locale
    session[:locale] = params[:locale] if params.key?(:locale)
    session[:locale] ||= extract_locale_from_accept_language_header
    session[:locale] ||= I18n.default_locale

    unless I18n.available_locales.map(&:to_s).include?(session[:locale].to_s)
      fail ActionController::RoutingError, "Unknown locale #{session[:locale]}"
    end

    I18n.locale = session[:locale]
  end

  def extract_locale_from_accept_language_header
    return unless request.env.key?('HTTP_ACCEPT_LANGUAGE')
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def redirect_to_root
    redirect_to root_url
    return false
  end
end
