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
        registry.detect { |rights| rights.api_query == value }
      end
    end

    def api_query
      super || pattern + '*'
    end

    def i18n_key
      id.to_s.tr('_', '-')
    end

    def label
      I18n.t("advanced-#{i18n_key}", scope: 'global.facet.reusability')
    end
  end
end
