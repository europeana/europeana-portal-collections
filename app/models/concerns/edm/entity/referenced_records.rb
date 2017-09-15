# frozen_string_literal: true

module EDM
  module Entity
    module ReferencedRecords
      include RepositoryHelper
      extend ActiveSupport::Concern

      def unreferenced?
        referenced_records[:total][:value] == 0
      end

      def referenced_records
        @refereneced_records ||= begin
          return { search_results: [], total: { value: 0, formatted: '0' } } unless self.respond_to?(:search_query)
          @response = repository.search(query: search_query)
          {
            search_results: @response[:items],
            total: {
              value: @response["totalResults"],
              formatted: number_with_delimiter(@response["totalResults"])
            }
          }
        end
      end
    end
  end
end
