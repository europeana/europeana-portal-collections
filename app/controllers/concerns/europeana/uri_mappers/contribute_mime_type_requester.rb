# frozen_string_literal: true

module Europeana
  module URIMappers
    class ContributeMimeTypeRequester < Base
      # Overriden to handle parallel requests
      def run
        requestable_uris = super
        head_responses = {}
        benchmark("[Europeana Contribute MIME type lookup (in parallel for #{uris.count})]", level: :info) do
          faraday_connection.in_parallel do
            requestable_uris.each_pair do |uri, req_uri|
              head_responses[uri] = faraday_connection.head(req_uri)
            end
          end
        end
        head_responses.each_with_object({}) do |(uri, response), memo|
          location = response.headers['Location']
          memo[uri] = MIME::Types.of(location)&.first&.content_type
        end
      end

      def map_one_uri(uri)
        uri.sub('http:', 'https:')
      end

      def faraday_connection
        @faraday_connection ||= Faraday.new do |conn|
          conn.adapter :typhoeus
        end
      end

      # TODO: return false if web resource has mime type already
      def uri_mappable?(uri)
        uri.start_with?('http://contribute.europeana.eu')
      end

      def runnable?
        true
      end
    end
  end
end
