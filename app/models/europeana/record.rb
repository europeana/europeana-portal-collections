# frozen_string_literal: true

##
# Represents (but does not store) a Europeana record as exposed over the Record
# API.
#
# @see http://labs.europeana.eu/api/record
module Europeana
  class Record
    include Europeana::Record::Annotations

    ID_PATTERN = %r{\A/[^/]+/[^/]+\z}

    attr_accessor :id

    class << self
      ##
      # Extracts a Europeana record ID from a variety of known portal URL formats
      #
      # @param url [String] URL to extract from
      # @return [String] Europeana ID
      def id_from_portal_url(url)
        uri = URI.parse(url)
        return nil unless %w(http https).include?(uri.scheme)
        return nil unless uri.host == 'www.europeana.eu'
        extension = /\.[a-z]+\z/i.match(uri.path)
        return nil unless extension.nil? || extension[0] == '.html'
        match = %r|\A/portal(/[a-z]{2})?/record(/[^/]+/[^/]+)#{extension}\z|.match(uri.path)
        match.nil? ? nil : match[2]
      end

      ##
      # Constructs a Search API query for all of the passed IDS.
      #
      # This only returns what would need to go in the `query` parameter sent to
      # the API (or Blacklight's `q` parameter), nothing else. The caller will need
      # to ensure that other parameters are set, such as ensuring that the API
      # returns enough rows to get the entire gallery back.
      #
      # @param record_ids [Array<String>]
      # @return [String]
      def search_api_query_for_record_ids(record_ids)
        'europeana_id:("' + record_ids.join('" OR "') + '")'
      end
    end

    def initialize(id)
      self.id = id
    end

    ##
    # Returns the language-agnostic portal URL for this Europeana record
    #
    # @return [String]
    def portal_url
      "http://www.europeana.eu/portal/record#{id}.html"
    end
  end
end
