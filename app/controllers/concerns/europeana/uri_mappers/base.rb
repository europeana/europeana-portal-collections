# frozen_string_literal: true
module Europeana
  module URIMappers
    class Base
      include ActiveSupport::Benchmarkable

      def initialize(doc, controller)
        @doc = doc
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
        @doc.fetch('aggregations.edmIsShownBy', []) || []
      end

      def web_resources_about
        @doc.fetch('aggregations.webResources.about', []) || []
      end
    end
  end
end
