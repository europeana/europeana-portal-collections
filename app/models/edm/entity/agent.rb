# frozen_string_literal: true

module EDM
  module Entity
    class Agent < EDM::Entity::Base
      has_human_type 'person'

      def description
        entity_value_by_locale(entity_response[:biographicalInformation])
      end

      def tabs
        {
          items_by: search_path(locale: locale, q: search_query)
        }
      end

      def anagraphical
        result = [
          {
            label: t('site.entities.anagraphic.birth'),
            value: entity_birth
          },
          {
            label: t('site.entities.anagraphic.death'),
            value: entity_death
          },
          {
            label: t('site.entities.anagraphic.occupation'),
            value: entity_occupation
          }
        ].reject { |item| item[:value].nil? }

        result.size.zero? ? nil : result
      end

      private

      def search_query
        @q ||= "proxy_dc_creator: \"#{build_url(id)}\" OR proxy_dc_contributor: \"#{build_url(id)}\""
      end

      def build_url(id)
        "http://data.europeana.eu/agent/base/#{id}"
      end
    end
  end
end
