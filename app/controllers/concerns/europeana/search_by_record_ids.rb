# frozen_string_literal: true

module Europeana
  module SearchByRecordIds
    extend ActiveSupport::Concern

    include ApiHelper

    protected

    # Queries the Search API for Europeana records by their ID
    #
    # Up to 100 IDs will be requested at once, resulting in multiple API
    # requests if more than 100 are passed in.
    #
    # @param europeana_ids [Array<String>] Europeana record IDs
    # @param blacklight [Boolean] If true, use Blacklight and return document
    #   objects, otherwise return hashes of data straight from API JSON response
    # @param options [Hash] Any other options are passed on to +Europeana::API+
    #   or +Blacklight+
    # @return [Hash{String => Hash},Hash{String => Europeana::Blacklight::Document}]
    #   Search results keyed by Europeana record ID
    def search_results_for_europeana_ids(europeana_ids, blacklight: false, **options)
      id_count = europeana_ids.count
      return {} if id_count.zero?

      per_page = blacklight ? blacklight_config.per_page.max : 100
      pages = id_count / per_page + 1
      paged_ids = europeana_ids.each_slice(per_page).to_a

      {}.tap do |results|
        page = 0
        while page < pages
          page_of_ids = paged_ids[page]
          id_query = Europeana::Record.search_api_query_for_record_ids(page_of_ids)

          if blacklight
            blacklight_params = { q: id_query, per_page: per_page }.reverse_merge(options)
            search_results(blacklight_params).last.each do |document|
              results[document.id] = document
            end
          else
            response = Europeana::API.record.search(options.merge(api_url: api_url, rows: per_page, query: id_query))
            response[:items].each do |item|
              results[item['id']] = item
            end
          end
          page += 1
        end
      end
    end
  end
end
