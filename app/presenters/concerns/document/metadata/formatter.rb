# frozen_string_literal: true

module Document
  module Metadata
    module Formatter
      extend ActiveSupport::Concern

      include DateHelper
      include GeolocationHelper

      def format_text(text, format)
        case format
        when :date
          format_date(text)
        when :latitude
          format_latitude(text)
        when :longitude
          format_longitude(text)
        else
          text
        end
      end
    end
  end
end
