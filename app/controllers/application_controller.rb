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

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def redirect_to_root
    redirect_to root_url
    return false
  end

  def current_user
    super || User.new
  end
end
