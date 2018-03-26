# frozen_string_literal: true

module Europeana
  module URIMappers
    extend ActiveSupport::Concern

    def perform_url_conversions(document)
      [SoundCloudUrnResolver, TelQueryAppender].each_with_object({}) do |klass, conversions|
        converter = klass.new(document, self)
        if converter.runnable?
          conversions.merge!(converter.run)
        end
      end
    end

    def perform_media_header_requests(document)
      mapper = ContributeHeadersRequester.new(document, self)
      mapper.runnable? ? mapper.run : {}
    end
  end
end
