module Europeana
  module Blacklight
    class SearchBuilder
      ##
      # Search builder with content channel qf
      module Channels
        def add_channel_qf_to_api(api_parameters)
          return unless blacklight_params[:controller] == 'channels' && blacklight_params[:id].present?
          channel_qf = scope.channels_search_query
          return if channel_qf.blank?
          api_parameters[:qf] ||= []
          api_parameters[:qf] << channel_qf
        end
      end
    end
  end
end
