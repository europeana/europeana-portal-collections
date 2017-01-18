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
    url_for(params.merge(locale: locale, only_path: false))
  end

  def current_url_without_locale
    url_for(params.merge(only_path: false)).sub("/#{I18n.locale}", '')
  end
end
