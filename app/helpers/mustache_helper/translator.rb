module MustacheHelper
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
        fail I18n::MissingTranslationData.new(I18n.locale, @parent_keys.join('.'), {}).to_exception
      elsif translation.is_a?(String)
        I18n.interpolate_hash(translation, @scope)
      else
        self.class.new(@scope, translation, @parent_keys + [key])
      end
    rescue I18n::MissingTranslationData => e
      keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
      "translation missing: #{keys.join('.')}"
    end

    def to_hash
      self
    end

    def to_s
      "translation missing: #{@parent_keys.join('.')}"
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
