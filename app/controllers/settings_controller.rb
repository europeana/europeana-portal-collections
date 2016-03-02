##
# User settings controller
class SettingsController < ApplicationController
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
        if local_redirect
          redirect_to local_redirect
        else
          render action: :language, status: flash_status
        end
      end
      format.json do
        render json: flash_json.merge(refresh: (locales.first != locales.last)),
               status: flash_status
      end
    end
  end

  protected

  ##
  # Ensure that only local paths are accepted as redirect targets
  def local_redirect
    @local_redirect ||= begin
      if params[:redirect] && params[:redirect].is_a?(String) && params[:redirect] =~ %r{\A/}
        params[:redirect]
      end
    end
  end

  def flash_status
    flash.key?(:alert) ? 400 : 200
  end

  def flash_json
    {
      success: !flash.key?(:alert),
      message: flash.key?(:alert) ? flash.now[:alert] : flash.now[:notice]
    }
  end

  ##
  # Attempts to set the session locale from the locale request param
  #
  # @return [Array<Symbol>] Two elements: first is old session locale, last is
  #   current session locale
  def set_locale_from_param
    session_locale_was = session[:locale]

    begin
      I18n.locale = params[:locale] if params[:locale]
      flash.now[:notice] = t('site.settings.language.flash.notice')
    rescue I18n::InvalidLocale
      flash.now[:alert] = t('site.settings.language.flash.alert', locales: I18n.available_locales.map(&:to_s).join(','))
    end

    session[:locale] = I18n.locale
    [session_locale_was, session[:locale]]
  end
end
