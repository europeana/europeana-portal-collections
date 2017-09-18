# frozen_string_literal: true

module EDM
  module Entity
    module ReferencedRecords
      include RepositoryHelper
      extend ActiveSupport::Concern

      def unreferenced?
        !referenced_records.detect { |_key, records| records[:total][:value] != 0 }
      end

      def referenced_records
        @refereneced_records ||= {}
        search_keys.each do |key|
          @refereneced_records[key] ||= begin
            return { search_results: [], total: { value: 0, formatted: '0' } } unless self.respond_to?(:search_query)
            @response = Europeana::Blacklight::Response.new(repository.search(query: search_query), controller.params)
            {
              search_results: @response.documents.map { |doc| document_presenter(doc).content },
              total: {
                value: @response.total,
                formatted: number_with_delimiter(@response.total)
              }
            }
          end
        end
        @refereneced_records
      end

      def document_presenter(doc)
        Document::SearchResultPresenter.new(doc, controller, @response, blacklight_config)
      end

      def controller
        @controller ||= OpenStruct.new({ params: { q: search_query } })
      end
    end
  end
end
