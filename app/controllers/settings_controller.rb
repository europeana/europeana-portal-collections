##
# User settings controller
class SettingsController < ApplicationController
  include Europeana::Styleguide

  ##
  # @todo move this into two separate actions, one for GET, one for PUT, with
  #  a resourceful controller and routes, per http://guides.rubyonrails.org/routing.html#singular-resources
  def language
    if request.put?
      locale_changed = set_locale_from_param

      respond_to do |format|
        format.html do
          render action: :language, status: status_from_flash
        end
        format.json do
          render json: { success: !flash.key?(:alert), refresh: locale_changed,
                         message: flash.key?(:alert) ? flash.now[:alert] : flash.now[:notice] },
                 status: status_from_flash
        end
      end
    else
      respond_to do |format|
        format.html
      end
    end
  end

  protected

  def status_from_flash
    flash.key?(:alert) ? 400 : 200
  end

  def set_locale_from_param
    locale_changed = false

    if params[:locale]
      locale_param = params[:locale].to_sym
      if I18n.available_locales.include?(locale_param)
        if session[:locale] != locale_param
          session[:locale] = locale_param
          locale_changed = true
        end
      else
        flash.now[:alert] = 'Invalid language specified. Available languages: ' + I18n.available_locales.map(&:to_s).join(',')
      end
    end

    flash.now[:notice] = 'Language settings saved.' unless flash.key?(:alert)

    locale_changed
  end
end
