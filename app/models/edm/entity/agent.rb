# frozen_string_literal: true

module EDM
  module Entity
    class Agent < EDM::Entity::Base
      humanized_as 'person'

      # agent => biographicalInformation: [
      #   {
      #     @language: "en",
      #     @value: "..."
      #   },
      #   ...
      # ]
      def description
        value_by_locale(api_response[:biographicalInformation])
      end

      def birth_date
        date(api_response[:dateOfBirth])
      end

      def birth_place
        place(api_response[:placeOfBirth])
      end

      def birth
        date_and_place(birth_date, birth_place)
      end

      def death_date
        date(api_response[:dateOfDeath])
      end

      def death_place
        place(api_response[:placeOfDeath])
      end

      def death
        date_and_place(death_date, death_place)
      end

      # For multiple items the format is just an array of hash items
      #
      # professionOrOccupation: [
      #   {
      #     @id: "http://dbpedia.org/resource/Pianist",
      #   },
      #   -and/or-
      #   {
      #     @language: "en",
      #     @value: "occupation1, occupation2, ..."
      #   },
      #   ...
      # ]
      #
      # where for single items we can remove the brackets and the format is
      # just a hash:
      #
      # professionOrOccupation:{
      #   ...
      # }
      #
      # Returns an array of strings
      def occupation
        result = value(api_response[:professionOrOccupation])
        if result.is_a?(String)
          result = result.split(',')
        elsif result.is_a?(Array)
          result = format_resource_urls(result)
        end
        result
      end

      def search_query
        @q ||= "proxy_dc_creator: \"#{build_url(id)}\" OR proxy_dc_contributor: \"#{build_url(id)}\""
      end

      private

      def build_url(id)
        "http://data.europeana.eu/agent/base/#{id}"
      end
    end
  end
end
