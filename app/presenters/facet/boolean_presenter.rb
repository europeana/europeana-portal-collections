module Facet
  class BooleanPresenter < FacetPresenter
    def display(**_)
      {
        name: facet_name,
        title: facet_label,
        url: facet_url,
        text: facet_label,
        is_checked: facet_checked?,
        boolean: true
      }
    end

    def facet_url
      if boolean_facet_in_params?(@facet.name)
        search_action_url(remove_facet_params(facet_params(@facet.name).first))
      elsif facet_checked?
        search_action_url(search_state.add_facet_params_and_redirect(@facet.name, facet_config.boolean[:off]))
      else
        search_action_url(search_state.add_facet_params_and_redirect(@facet.name, facet_config.boolean[:on]))
      end
    end

    def facet_checked?
      if facet_config.boolean[:on].nil? && !boolean_facet_in_params?(@facet.name)
        true
      elsif !facet_config.boolean[:on].nil? && facet_in_params?(@facet.name, facet_config.boolean[:on])
        true
      else
        facet_config.boolean[:default] == :on
      end
    end

    def boolean_facet_in_params?(field)
      (facet_params(field) || []).present?
    end
  end
end
