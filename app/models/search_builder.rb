class SearchBuilder < Europeana::Blacklight::SearchBuilder
  self.default_processor_chain << :add_entity_query_to_api

  def salient_facets_for_api_facet_qf
    super.tap do |salient_facets|
      aliased_facets_for_api_facet_qf.each_pair do |k, v|
        salient_facets[k] ||= []
        salient_facets[k] += v
      end
    end
  end

  def aliased_facets_in_params
    blacklight_config.facet_fields.select do |field_name, facet|
      blacklight_params[:f].key?(field_name) && facet.aliases.present?
    end
  end

  def aliased_facets_for_api_facet_qf
    aliased_facets_in_params.each_with_object({}) do |(field_name, facet), aliased|
      aliased[facet.aliases] = blacklight_params[:f][field_name]
    end
  end

  def requestable_facet?(facet)
    super && !facet.aliases.present?
  end

  def add_entity_query_to_api(api_parameters)
    return unless blacklight_params[:qe]

    # Keys of qe param hash will be like "agent/base/145378"
    blacklight_params[:qe].each_pair do |entity_path, _label|
      type, namespace, id = entity_path.split('/')
      next if [type, namespace, id].any?(&:blank?)

      query_field = search_api_query_field_for_entity_type(type)
      next if query_field.nil?

      api_parameters[:qf] ||= []
      api_parameters[:qf] << %(#{query_field}:"http://data.europeana.eu/#{type}/#{namespace}/#{id}")
    end
  end

  def search_api_query_field_for_entity_type(entity_type)
    case entity_type
    when 'agent'
      'who'
    when 'concept'
      'what'
    when 'place'
      'where'
    when 'timespan'
      'when'
    end
  end
end
