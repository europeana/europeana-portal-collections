# frozen_string_literal: true

module EDM
  module Entity
    class Agent < EDM::Entity::Base
      has_human_type 'person'

      def description
        entity_value_by_locale(m[:biographicalInformation])
      end

      def search_query_fields
        ENTITY_SEARCH_QUERY_FIELDS = {
            agent: {
                by: %w(proxy_dc_creator proxy_dc_contributor)
            },
            concept: {
                about: 'what'
            }
        }.freeze

      end

      private

      def build_proxy_dc(name, url, path)
        %(proxy_dc_#{name}:"#{url}/#{path}")
      end

    end
  end
end
