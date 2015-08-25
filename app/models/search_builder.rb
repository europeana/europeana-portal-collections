##
# Blacklight search builder with portal-specific processors
class SearchBuilder < Europeana::Blacklight::SearchBuilder
  self.default_processor_chain << :add_overlay_params_to_api

  ##
  # "Overlay" params do not replace others, but are combined with them, into
  # multiple values for those param keys
  def with_overlay_params(overlay_params = {})
    @overlay_params = overlay_params.is_a?(String) ? Rack::Utils.parse_query(overlay_params) : overlay_params
    self
  end

  def add_overlay_params_to_api(api_parameters)
    return unless @overlay_params

    @overlay_params.each_pair do |k, v|
      k = k.to_sym
      if api_parameters.key?(k)
        api_parameters[k] = [api_parameters[k]].flatten # in case it's not an Array
      else
        api_parameters[k] = []
      end
      api_parameters[k] += [v]
      api_parameters[k] = api_parameters[k].flatten.uniq
    end
  end
end
