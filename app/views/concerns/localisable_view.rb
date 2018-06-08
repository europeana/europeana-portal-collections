# frozen_string_literal: true

##
# Localisation view methods
module LocalisableView
  extend ActiveSupport::Concern

  def page_locale
    session[:locale]
  end

  protected

  def url_without_params(url)
    url.gsub(/\?.*/, '')
  end

  def current_url_for_locale(locale)
    controller.request.original_url.sub("/#{I18n.locale}", "/#{locale}")
  end

  def current_url_without_locale
    controller.request.original_url.sub("/#{I18n.locale}", '')
  end
end
