module EDM
  class Rights < Base
    class << self
      def registry
        @registry ||= begin
          registry_entries.flat_map do |reusability, entries|
            entries.map do |id, attrs|
              new({ id: id.to_sym, reusability: reusability }.merge(attrs || {}))
            end
          end
        end
      end

      def normalise(string)
        return nil unless string.is_a?(String)
        registry.detect { |rights| string.match(rights.pattern) }
      end

      def for_api_query(value)
        registry.detect { |rights| Regexp.new(rights.pattern) =~ value }
      end

      def from_api_query(value)
        unescaped_value = value.to_s.gsub('?', '').gsub('*', '')
        registry.detect { |rights| Regexp.new(rights.pattern) =~ unescaped_value }
      end
    end

    def api_query
      super || pattern.sub(/\(.*\)\?|.\?/, '*') + '*'
    end

    def i18n_key
      id.to_s.tr('_', '-')
    end

    def label
      label = I18n.t("advanced-#{i18n_key}", scope: 'global.facet.reusability')
      return label unless label.blank? && (I18n.locale != I18n.default_locale)
      I18n.t("advanced-#{i18n_key}", scope: 'global.facet.reusability', locale: I18n.default_locale)
    end
  end
end
