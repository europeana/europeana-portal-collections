class SearchBuilder < Europeana::Blacklight::SearchBuilder
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
end
