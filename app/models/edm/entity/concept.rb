# frozen_string_literal: true

module EDM
  module Entity
    class Concept < Base
      has_human_type 'topic'

      def description
        note = m[:note]
        return nil unless note.present? && note.is_a?(Hash)
        if note.key?(locale.to_sym)
          note[locale.to_sym].first
        elsif note.key?(:en)
          note[:en].first
        end
      end

      def search_query_fields
        {
          agent: {
            by: %w(proxy_dc_creator proxy_dc_contributor)
          },
          concept: {
            about: 'what'
          }
        }
      end
    end
  end
end
