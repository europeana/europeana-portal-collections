##
# A custom class for this project's Mustache templates
#
# Each page-specific view class should sub-class this.
#
# Public methods added to this class will be available to all Mustache
# templates.
class ApplicationView < Europeana::Styleguide::View
  include MustacheHelper

  def cached_body
    lambda do |text|
      Rails.cache.fetch(cache_key, expires_in: 24.hours, force: !cache_body?) do
        render(text)
      end
    end
  end

  protected

  def site_title
    'Europeana Collections'
  end

  private

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
    keys = ['views', cache_version, I18n.locale.to_s, controller.current_user.role || 'guest', body_cache_key]
    keys.compact.join('/')
  end

  # Implement this method in sub-classes to enable body caching
  def body_cache_key
    fail NotImplementedError
  end

  def cache_body?
    !request.format.json?
  end
end
