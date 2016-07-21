##
# Methods for caching rendered view content
module CacheableView
  extend ActiveSupport::Concern

  def cached_body
    lambda do |text|
      if cache_body?
        Rails.cache.fetch(cache_key, expires_in: 24.hours) { render(text) }
      else
        render(text)
      end
    end
  end

  protected

  def cache_version
    @cache_version ||= begin
      v = Rails.application.config.assets.version.dup
      unless Rails.application.config.x.cache_version.blank?
        v << ('-' + Rails.application.config.x.cache_version.dup)
      end
      v
    end
  end

  def cache_key
    keys = ['views', cache_version, I18n.locale.to_s, devise_user.role || 'guest', body_cache_key]
    keys.compact.join('/')
  end

  # Implement this method in sub-classes to enable body caching
  def body_cache_key
    fail NotImplementedError
  end

  def cache_body?
    !request.format.json? && !ENV['DISABLE_VIEW_CACHING']
  end
end
