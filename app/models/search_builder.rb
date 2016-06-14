class SearchBuilder < Europeana::Blacklight::SearchBuilder
  ##
  # Overrides Europeana::Blacklight::SearchBuilder method for alias handling
  def add_facet_qf_to_api(api_parameters)
    return unless blacklight_params[:f]

    salient_facets = blacklight_params[:f].select do |k, _v|
      !STANDALONE_FACETS.include?(k) && api_request_facet_fields.keys.include?(k)
    end

    salient_facets.each_pair do |facet_field, value_list|
      facet_config = blacklight_config.facet_fields[facet_field]
      qf_field = facet_config.aliases.present? ? facet_config.aliases : facet_field

      Array(value_list).reject(&:blank?).each do |value|
        api_parameters[:qf] ||= []
        api_parameters[:qf] << "#{qf_field}:" + quote_facet_value(facet_field, value)
      end
    end
  end

  ##
  # Overrides Europeana::Blacklight::SearchBuilder method for alias handling
  def add_facetting_to_api(api_parameters)
    api_parameters[:facet] = api_request_facet_fields.keys.map do |field|
      facet_config = blacklight_config.facet_fields[field]
      case
      when Europeana::API::Search::Fields::MEDIA.include?(field)
        'DEFAULT'
      when facet_config.aliases.present?
        facet_config.aliases
      else
        field
      end
    end.uniq.join(',')

    api_request_facet_fields.each do |field_name, facet|
      api_parameters[:"f.#{facet.field}.facet.limit"] = facet_limit_for(field_name) if facet_limit_for(field_name)
    end
  end
end
