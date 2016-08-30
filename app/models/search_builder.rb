class SearchBuilder < Europeana::Blacklight::SearchBuilder
  ##
  # Overrides Europeana::Blacklight::SearchBuilder method for alias handling
  def add_facet_qf_to_api(api_parameters)
    return unless blacklight_params[:f]

    salient_facets = salient_facets_for_api_facet_qf

    salient_facets.each_pair do |facet_field, value_list|
      Array(value_list).reject(&:blank?).each do |value|
        api_parameters[:qf] ||= []
        api_parameters[:qf] << "#{facet_field}:" + quote_facet_value(facet_field, value)
      end
    end
  end

  def salient_facets_for_api_facet_qf
    Hash[blacklight_params[:f].map do |k, v|
      next [nil, nil] if STANDALONE_FACETS.include?(k)

      salient_facet = [k, v] if api_request_facet_fields.keys.include?(k)
      salient_facet = [blacklight_config.facet_fields[k].aliases, v] if blacklight_config.facet_fields[k].aliases
      salient_facet || [nil, nil]
    end]
  end

  ##
  # Overrides Europeana::Blacklight::SearchBuilder method for alias handling
  def api_request_facet_fields
    @api_request_facet_fields ||= Hash[blacklight_config.facet_fields.map do |field_name, facet|
      if !facet.query &&
         (facet.include_in_request || (facet.include_in_request.nil? && blacklight_config.add_facet_fields_to_solr_request))
        if facet.aliases.present?
          [[facet.aliases, blacklight_config.facet_fields[facet.aliases]], [field_name,  facet]]
        else
          [field_name,  facet]
        end
      else
        [nil, nil]
      end
    end]
  end
end
