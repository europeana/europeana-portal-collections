# frozen_string_literal: true
module CacheHelper
  def cache_version
    @cache_version ||= begin
      v = Rails.application.config.assets.version.dup
      unless Rails.application.config.x.cache_version.blank?
        v << ('-' + Rails.application.config.x.cache_version.dup)
      end
      v
    end
  end

  def cache_key(body_cache_key, locale: I18n.locale.to_s, user_role: current_user.role || 'guest')
    keys = ['views', cache_version, locale, user_role, body_cache_key]
    keys.compact.join('/')
  end

  def cache_body?
    !request.format.json? && !config.x.disable.view_caching
  end

  def body_cached?
    cache_body? && Rails.cache.exist?(cache_key(body_cache_key))
  end

  def expire_cache(body_cache_key)
    I18n.available_locales.each do |locale|
      (User.role_enum + %w(guest)).each do |user_role|
        Rails.cache.delete(cache_key(body_cache_key, locale: locale, user_role: user_role))
      end
    end
  end
end
