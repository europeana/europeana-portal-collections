# frozen_string_literal: true

module SessionLocale
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  # Set session & request locale
  #
  # 1. If locale is in URL, use that. If this locale is unsupported, 404.
  # 2. Else if locale is already in session storage, use that. If this locale is
  #    unsupported, ignore it.
  # 3. Else if locale is in Accept-Language header, use that. If this locale is
  #    unsupported, ignore the header.
  # 4. Otherwise use the default locale, English.
  def set_locale
    set_session_locale_from_url ||
      locale_in_session? ||
      set_session_locale_from_accept_language_header ||
      set_session_locale_from_default
    I18n.locale = session[:locale]
  end

  def set_session_locale_from_url
    return false unless params.key?(:locale)
    fail ActionController::RoutingError, "Unknown locale #{params[:locale]}" unless available_locales.include?(params[:locale].to_s)
    session[:locale] = params[:locale]
    true
  end

  def locale_in_session?
    return false unless session.key?(:locale)
    return true if available_locales.include?(session[:locale].to_s)
    session.delete(:locale)
    false
  end

  def set_session_locale_from_accept_language_header
    session[:locale] ||= extract_locale_from_accept_language_header
    return true if available_locales.include?(session[:locale].to_s)
    session.delete(:locale)
    false
  end

  def set_session_locale_from_default
    session[:locale] ||= I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    return unless request.env.key?('HTTP_ACCEPT_LANGUAGE')
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end
end
