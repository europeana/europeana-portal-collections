# frozen_string_literal: true

##
# Main application controller
class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include ControllerExceptionHandling
  include Europeana::Styleguide
  include Catalog
  include DefaultUrlOptions
  include SessionLocale

  helper Europeana::Feeds::Engine.helpers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  delegate :available_locales, to: :class

  before_action :permit_iframing, :set_request_fullpath

  layout proc { is_a?(Europeana::Styleguide) ? false : 'application' }

  def self.available_locales
    @available_locales ||= I18n.available_locales.map(&:to_s)
  end

  def csrf
    respond_to do |format|
      format.json do
        render json: {
          param: request_forgery_protection_token,
          token: form_authenticity_token
        }
      end
    end
  end

  def status
    render plain: 'OK'
  end

  def current_user
    super || User.new(guest: true)
  end

  private

  def permit_iframing
    response.headers.delete('X-Frame-Options') if ENV['DELETE_X_FRAME_OPTIONS_RESPONSE_HEADER']
  end

  def redirect_to_home
    redirect_to home_url
    false
  end

  def set_request_fullpath
    @request_fullpath = request.fullpath
  end
end
