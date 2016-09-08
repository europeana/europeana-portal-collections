module Europeana
  module UrlConversions
    extend ActiveSupport::Concern

    def perform_url_conversions(doc)
      [SoundCloudUrnResolver, TelQueryAppender].each_with_object({}) do |klass, conversions|
        converter = klass.new(doc, self)
        if converter.is_runnable?
          conversions.merge!(converter.run)
        end
      end
    end
  end
end
