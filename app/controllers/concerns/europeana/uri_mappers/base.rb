# frozen_string_literal: true

module Europeana
  module URIMappers
    class Base
      include ActiveSupport::Benchmarkable

      attr_reader :controller, :document

      # @param document [Europeana::Blacklight::Document] Blacklight document for the record
      # @param controller [ApplicationController] controller handling the request
      def initialize(document, controller)
        @document = document
        @controller = controller
      end

      def logger
        Rails.logger
      end

      def run
        uris.each_with_object({}) do |uri, map|
          map[uri] = map_one_uri(uri) if uri_mappable?(uri)
        end
      end

      def uris
        edm_is_shown_by + web_resources_about
      end

      def edm_is_shown_by
        document.fetch('aggregations.edmIsShownBy', []) || []
      end

      def web_resources_about
        document.fetch('aggregations.webResources.about', []) || []
      end

      def web_resource_for(uri)
        document.fetch('aggregations.webResources').detect { |web_resource| web_resource['about'] == uri }
      end
    end
  end
end
