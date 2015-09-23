##
# User settings controller
class SettingsController < ApplicationController
  include Europeana::Styleguide

  # GET language
  # @todo move this into a resourceful controller and routes for Settings::Languages
  #   per http://guides.rubyonrails.org/routing.html#singular-resources
  def language
    respond_to do |format|
      format.html
    end
  end

  # PUT language
  def update_language
    locales = set_locale_from_param
    
    respond_to do |format|
      format.html do
        render action: :language, status: status_from_flash
      end
      format.json do
        render json: { success: !flash.key?(:alert), refresh: (locales.first != locales.last),
                       message: flash.key?(:alert) ? flash.now[:alert] : flash.now[:notice] },
               status: status_from_flash
      end
    end
  end

  protected

  def status_from_flash
    flash.key?(:alert) ? 400 : 200
  end

  ##
  # Attempts to set the session locale from the locale request param
  #
  # @return [Array<Symbol>] Two elements: first is old session locale, last is
  #   current session locale
  def set_locale_from_param
    session_locale_was = session[:locale]

    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.locale = params[:locale]
        session[:locale] = I18n.locale
      else
        flash.now[:alert] = 'Invalid language specified. Available languages: ' + I18n.available_locales.map(&:to_s).join(',')
      end
    end
    flash.now[:notice] = 'Language settings saved.' unless flash.key?(:alert)

    [session_locale_was, session[:locale]]
  end
end
