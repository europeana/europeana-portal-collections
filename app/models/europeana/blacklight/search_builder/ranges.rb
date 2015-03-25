module Europeana
  module Blacklight
    class SearchBuilder
      ##
      # Search builder with content channel qf
      module Ranges
        extend ActiveSupport::Concern

        included do
          default_processor_chain << :add_range_qf_to_api
        end

        def add_range_qf_to_api(api_parameters)
          return unless blacklight_params.key?(:range) && blacklight_params[:range].is_a?(Hash)
          blacklight_params[:range].each_pair do |range_field, range_values|
            api_parameters[:qf] ||= []
            api_parameters[:qf] << "#{range_field}:[#{range_values[:begin]} TO #{range_values[:end]}]"
          end
        end
      end
    end
  end
end
