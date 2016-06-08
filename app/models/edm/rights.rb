module EDM
  class Rights < OpenStruct
    def self.registry
      @registry ||= begin
        rights = YAML.load_file(File.join(Rails.root, 'config', 'edm_rights.yml'))
        rights.map do |id, attrs|
          new({ id: id.to_sym }.merge(attrs))
        end
      end
    end

    def self.normalise(string)
      return nil unless string.is_a?(String)
      registry.detect { |rights| string.match(rights.pattern) }
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
