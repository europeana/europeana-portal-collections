# frozen_string_literal: true

module Europeana
  module SearchByRecordIds
    extend ActiveSupport::Concern

    protected

    # Queries the Search API for Europeana records by their ID
    #
    # Up to 100 IDs will be requested at once, resulting in multiple API
    # requests if more than 100 are passed in.
    #
    # @param europeana_ids [Array<String>] Europeana record IDs
    # @return [Hash{String => Europeana::Blacklight::Document}]
    #   Search result documents keyed by Europeana record ID
    def search_results_for_europeana_ids(europeana_ids)
      id_count = europeana_ids.count
      return {} if id_count.zero?

      per_page = 100
      pages = id_count / per_page + 1
      paged_ids = europeana_ids.each_slice(per_page).to_a

      {}.tap do |results|
        page = 0
        while page < pages
          page_of_ids = paged_ids[page - 1]
          id_query = Europeana::Record.search_api_query_for_record_ids(page_of_ids)

          blacklight_params = { q: id_query, per_page: per_page }
          search_results(blacklight_params).last.each do |document|
            results[document.id] = document
          end
          page += 1
        end
      end
    end
  end
end
