module I18nHelper
  class Translator
    def initialize(scope)
      @scope = scope
    end

    def [](key)
      I18n.translate(key, @scope)
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
