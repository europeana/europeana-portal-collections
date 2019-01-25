# frozen_string_literal: true

require 'active_support/number_helper/number_to_rounded_converter'

module ActiveSupport
  module NumberHelper
    class NumberToRoundedConverter
      # Patch to quiet warnings for deprecated `BigDecimal.new` in Ruby 2.6
      def calculate_rounded_number(multiplier)
        (number / BigDecimal(multiplier.to_f.to_s)).round * multiplier
      end
    end
  end
end
