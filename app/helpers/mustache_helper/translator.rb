module MustacheHelper
  # @todo move into extension of Mustache renderer, detecting template variables
  #   starting with "i18n."?
  class Translator
    include ActionView::Helpers::TagHelper

    def initialize(scope, data = {}, parent_keys = [])
      @scope = scope
      @data = data
      @parent_keys = parent_keys
    end

    def [](key)
      translation = @data.present? ? @data[key] : I18n.translate(key, raise: true)
      if translation.nil?
        fail I18n::MissingTranslation.new(I18n.locale, @parent_keys.join('.'), {}).to_exception
      elsif translation.is_a?(String)
        I18n.interpolate_hash(translation, @scope)
      else
        self.class.new(@scope, translation, @parent_keys + [key])
      end
    rescue I18n::MissingTranslationData => e
      keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
      content_tag('span', keys.last.to_s.titleize, :class => 'translation_missing', :title => "translation missing: #{keys.join('.')}").html_safe
    end

    def to_hash
      self
    end

    def key?(key)
      I18n.exists?(key)
    end
    alias_method :has_key?, :key?

    def fetch(key, default = nil)
      self[key] || default
    end
  end
end
