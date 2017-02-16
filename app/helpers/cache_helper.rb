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

  def cache_key(body_cache_key)
    keys = ['views', cache_version, I18n.locale.to_s, current_user.role || 'guest', body_cache_key]
    keys.compact.join('/')
  end

  def cache_body?
    !request.format.json? && !ENV['DISABLE_VIEW_CACHING']
  end

  def body_cached?
    cache_body? && Rails.cache.exist?(cache_key(body_cache_key))
  end
end
