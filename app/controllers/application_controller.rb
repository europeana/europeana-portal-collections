##
# Main application controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include ControllerExceptionHandling

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  layout proc { kind_of?(Europeana::Styleguide) ? false : 'application' }

  def current_user
    super || User.new(guest: true)
  end

  def cache_path_prefix
    Rails.application.config.x.cache_version + '/'
  end

  def default_url_options
    if ENV['HTTP_HOST']
      { host: ENV['HTTP_HOST'] }
    else
      {}
    end
  end

  private

  def set_locale
    session[:locale] ||= I18n.default_locale
    I18n.locale = session[:locale]
  end

  def redirect_to_root
    redirect_to root_url
    return false
  end
end
