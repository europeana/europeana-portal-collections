module EDM
  class Rights < Base
    class << self
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

    def label
      key = id.to_s.tr('_', '-')
      return_label = I18n.t("advanced-#{key}", scope: 'global.facet.reusability')
      return_label = I18n.t("advanced-#{key}", scope: 'global.facet.reusability', locale: :en) if return_label.blank?
      return_label
    end
  end
end
