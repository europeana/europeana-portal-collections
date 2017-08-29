# frozen_string_literal: true

module EDM
  module Entity
    class Concept < Base
      has_human_type? 'topic'

      def description
        note = m[:note]
        return nil unless note.present? && note.is_a?(Hash)
        if note.key?(locale.to_sym)
          note[locale.to_sym].first
        elsif note.key?(:en)
          note[:en].first
        end
      end

      def tab_items
        [
          {
            tab_title: t('site.entities.tab_items.items_about', name: name),
            url: search_path(locale: locale, q: search_query, format: 'json'),
            search_url: search_path(q: search_query)
          }
        ]
      end

      def anagraphical
        nil
      end

      private

      def search_query
        @q ||= "what: \"http://data.europeana.eu/agent/base/#{id}\""
      end
    end
  end
end
