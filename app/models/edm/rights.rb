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

      def normalised
        @normalised ||= {}
      end

      def normalise(string)
        return nil unless string.is_a?(String)
        normalised[string] ||= registry.detect { |rights| string.match(rights.pattern) }
      end

      def api_query_map
        @api_query_map ||= {}
      end

      def from_api_query(value)
        return nil if value.blank?
        api_query_map[value] ||= begin
          registry.detect { |rights| rights.api_query == value }
        end
      end
    end

    def api_query
      # TODO: instead of blanket replacing all parenthesised parts of patterns
      #   with "*", for /(this|that)/ patterns we should be constructing an
      #   OR query for the API, *but* that does not work with the RIGHTS field
      #   on the API at present. (It should.) Hence this for now.
      @api_query ||= (pattern.gsub(/\(.*\)\??|.\?/, '*') + '*').gsub('**', '*')
    end

    def i18n_key
      @i18n_key ||= id.to_s.tr('_', '-')
    end

    def label
      label = I18n.t(i18n_key, scope: 'global.facet.rights')
      return label unless label.blank? && (I18n.locale != I18n.default_locale)
      I18n.t(i18n_key, scope: 'global.facet.rights', locale: I18n.default_locale)
    end
  end
end
