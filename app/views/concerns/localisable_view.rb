##
# Localisation view methods
module LocalisableView
  extend ActiveSupport::Concern

  def page_locale
    session[:locale]
  end

  protected

  def current_url_for_locale(locale)
    url_for(params.merge(locale: locale, only_path: false))
  end

  def current_url_for_locale_without_params(locale)
    current_url_for_locale(locale).gsub(/\?.*/, '')
  end

  def current_url_without_locale_or_query
    url_for(params.merge(only_path: false).except(:q)).sub("/#{I18n.locale}", '')
  end
end
