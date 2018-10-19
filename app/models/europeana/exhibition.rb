# frozen_string_literal: true

module Europeana
  # Represents (but does not store) a Europeana Exhibition.
  #
  # @see https://github.com/europeana/europeana-virtual-exhibitions
  class Exhibition
    include ActiveModel::Model

    # Regexp to match Europeana Exhibition urls
    URL_PATTERN = %r|https?://.+/portal/[a-z]{2}/exhibitions/.+|

    attr_accessor :card_image, :card_text, :credit_image, :depth, :description, :full_image, :labels, :lang_code,
                  :slug, :title, :url

    class << self
      # Does the argument look like a Europeana exhibition url?
      #
      # @param candidate [String] String to test
      # @return [Boolean]
      def exhibition?(candidate)
        !!(candidate =~ /\A#{URL_PATTERN}\z/)
      end

      def find(url)
        return unless exhibition?(url) && url.start_with?(Rails.application.config.x.exhibitions.host)
        response = Faraday.get("#{url}.json")
        return unless response.success?
        json_response = JSON.parse(response.body)
        new(json_response)
      rescue Errno::ECONNREFUSED, JSON::ParserError, OpenSSL::SSL::SSLError
        nil
      end
    end

    def exhibition_root?
      depth == 2
    end
  end
end
