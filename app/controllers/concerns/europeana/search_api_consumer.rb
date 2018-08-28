# frozen_string_literal: true

module Europeana
  module SearchAPIConsumer
    extend ActiveSupport::Concern

    include ApiHelper

    protected

    # Queries the Search API for Europeana records by their ID
    #
    # Up to 100 IDs will be requested at once, resulting in multiple API
    # requests if more than 100 are passed in.
    #
    # @param europeana_ids [Array<String>] Europeana record IDs
    # @param options [Hash] Any other options are passed on to
    #   +Europeana::API::Record.search+.
    # @return [Hash{String => Hash} Search results keyed by Europeana record ID
    # TODO: make multiple requests in parallel?
    def search_results_for_europeana_ids(europeana_ids, **options)
      id_count = europeana_ids.count
      return {} if id_count.zero?

      per_page = 100
      pages = id_count / per_page + 1
      paged_ids = europeana_ids.each_slice(per_page).to_a

      {}.tap do |results|
        (0...pages).each do |page|
          page_of_ids = paged_ids[page]
          id_query = Europeana::Record.search_api_query_for_record_ids(page_of_ids)
          response = Europeana::API.record.search(options.merge(api_url: api_url, rows: per_page, query: id_query))

          response[:items].each do |item|
            results[item['id']] = item
          end
        end
      end
    end

    # Queries the Search API for Europeana records being part of another record
    #
    # Given two records:
    # * A having ID "/123/abc"
    # * B having ID "/123/def"
    #
    # Record B is part of record A if the EDM proxy for B has a dcterms:isPartOf
    # value equal to A's Europeana item URI: "http://data.europeana.eu/item/123/abc".
    #
    # @param europeana_id [String] Europeana record ID to search for parts of
    # @return see Europeana::API::Record.search
    def search_results_for_dcterms_is_part_of(europeana_id)
      search_options = {
        api_url: api_url, rows: blacklight_config.default_per_page, sort: 'europeana_id asc',
        query: %(proxy_dcterms_isPartOf:"http://data.europeana.eu/item#{europeana_id}")
      }
      Europeana::API.record.search(search_options)
    end
  end
end
