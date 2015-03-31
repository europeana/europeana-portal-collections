module View
  class Translator
    def initialize(scope, data = {})
      @scope = scope
      @data = data
    end

    def [](key)
      translation = @data.present? ? @data[key] : I18n.translate(key)
      if translation.is_a?(String)
        I18n.interpolate_hash(translation, @scope)
      else
        self.class.new(@scope, translation)
      end
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
