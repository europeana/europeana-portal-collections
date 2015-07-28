##
# Blacklight search builder with portal-specific processors
class SearchBuilder < Europeana::Blacklight::SearchBuilder
  def add_channel_qf_to_api(api_parameters)
    return unless scope.respond_to?(:channel_filter_params)

    scope.channel_filter_params.each_pair do |k, v|
      api_parameters[k] ||= []
      api_parameters[k] += [v].flatten
    end
  end
end
