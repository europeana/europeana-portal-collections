# frozen_string_literal: true

module EDM
  module Entity
    class Concept < Base
      humanized_as 'topic'

      # concept => note: {
      #   en: ["..."],
      # }
      def description
        note = api_response[:note]

        return nil unless note.present? && note.is_a?(Hash)

        if note.key?(I18n.locale.to_sym)
          note[I18n.locale.to_sym].first
        elsif note.key?(:en)
          note[:en].first
        end
      end

      def search_keys
        %i(items_about)
      end

      def search_query(search_key)
        case search_key
        when :items_about
          @q ||= "what: \"http://data.europeana.eu/topic/base/#{id}\""
        end
      end
    end
  end
end
