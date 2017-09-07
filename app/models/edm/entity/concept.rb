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

        if note.key?(locale.to_sym)
          note[locale.to_sym].first
        elsif note.key?(:en)
          note[:en].first
        end
      end

      def search_query
        @q ||= "what: \"http://data.europeana.eu/agent/base/#{id}\""
      end
    end
  end
end
