# frozen_string_literal: true
##
# Represents (but does not store) a Europeana record as exposed over the Record
# API.
#
# @see http://labs.europeana.eu/api/record
module Europeana
  class Record
    ID_PATTERN = %r{\A/[^/]+/[^/]+\z}

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
      # Returns the language-agnostic portal URL for Europeana record ID
      #
      # @return [String]
      def portal_url_from_id(id)
        "http://www.europeana.eu/portal/record#{id}.html"
      end
    end
  end
end
