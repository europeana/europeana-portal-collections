class View
  class Translator
    def initialize(scope, data = {})
      @scope = scope
      @data = data
    end

    def [](key)
      translation = @data.present? ? @data[key] : I18n.translate(key)
      if translation.is_a?(String)
        interpolate_object(translation, @scope)
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

    def interpolate_object(string, source)
      string.gsub(I18n::INTERPOLATION_PATTERN) do |match|
        if match == '%%'
          '%'
        else
          key = ($1 || $2).to_sym
          value = if source.respond_to?(key)
                    source.send(key)
                  else
                    I18n::config.missing_interpolation_argument_handler.call(key, source.class, string)
                  end
          value = value.call(values) if value.respond_to?(:call)
          $3 ? sprintf("%#{$3}", value) : value
        end
      end
    end
  end
end
