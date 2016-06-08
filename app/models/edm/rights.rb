module EDM
  class Rights < Base
    class << self
      def normalise(string)
        return nil unless string.is_a?(String)
        registry.detect { |rights| string.match(rights.pattern) }
      end
    end

    def api_query
      super || pattern + '*'
    end

    def label
      key = id.to_s.tr('_', '-')
      I18n.t("advanced-#{key}", scope: 'global.facet.reusability')
    end
  end
end
