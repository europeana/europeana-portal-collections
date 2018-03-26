# frozen_string_literal: true

require 'soundcloud'

module Europeana
  module URIMappers
    class SoundCloudUrnResolver < Base
      def uris
        edm_is_shown_by
      end

      def map_one_uri(uri)
        soundcloud_url(soundcloud_id(uri))
      rescue SoundCloud::ResponseError
        # do nothing, i.e. no mapping
      end

      def uri_mappable?(uri)
        !soundcloud_urn_match(uri).nil?
      end

      def runnable?
        ENV.key?('SOUNDCLOUD_CLIENT_ID')
      end

      protected

      def soundcloud_urn_match(uri)
        uri.match(/\Aurn:soundcloud:(.*)\z/)
      end

      def soundcloud_id(uri)
        soundcloud_urn_match(uri)[1]
      end

      ##
      # Queries SoundCloud API for track URL from its ID
      def soundcloud_url(id)
        benchmark("[SoundCloud API] #{id}", level: :info) do
          soundcloud_client.get("/tracks/#{id.strip}").permalink_url
        end
      end

      def soundcloud_client
        @soundcloud_client ||= begin
          SoundCloud.new(client_id: ENV['SOUNDCLOUD_CLIENT_ID'])
        end
      end
    end
  end
end
