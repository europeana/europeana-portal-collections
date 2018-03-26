# frozen_string_literal: true

module Europeana
  module URIMappers
    class ContributeHeadersRequester < Base
      # Overriden to handle parallel requests
      def run
        requestable_uris = super
        head_responses = {}

        # Request published web resource URLs
        # +FaradayMiddleware::FollowRedirects+ does not support parallelism.
        benchmark("[Europeana Contribute URI HEAD requests (in parallel for #{uris.count})]", level: :info) do
          faraday_connection.in_parallel do
            requestable_uris.each_pair do |uri, req_uri|
              head_responses[uri] = faraday_connection.head(req_uri)
            end
          end
        end

        # Follow redirects to Object Storage URLs
        benchmark("[Europeana Contribute follow redirects (in parallel for #{uris.count})]", level: :info) do
          faraday_connection.in_parallel do
            head_responses.each_pair do |uri, response|
              next unless response.headers['Location']
              head_responses[uri] = faraday_connection.head(response.headers['Location'])
            end
          end
        end

        head_responses.each_with_object({}) do |(uri, response), memo|
          memo[uri] = response.headers
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

      def uri_mappable?(uri)
        return false unless uri.start_with?('http://contribute.europeana.eu')
        !web_resource_has_ebucore_metadata?(uri)
      end

      def web_resource_has_ebucore_metadata?(uri)
        web_resource = web_resource_for(uri)
        %w(ebucoreHasMimeType ebucoreHeight ebucoreWidth).all? { |k| web_resource.key?(k) }
      end

      def runnable?
        true
      end
    end
  end
end
