# frozen_string_literal: true

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
      if boolean_facet_in_params?(facet_name)
        remove_facet_url(facet_params(facet_name).first)
      elsif facet_checked?
        add_facet_url(facet_config.boolean[:off])
      else
        add_facet_url(facet_config.boolean[:on])
      end
    end

    def facet_checked?
      if facet_config.boolean[:on].nil? && !boolean_facet_in_params?(facet_name)
        true
      elsif !facet_config.boolean[:on].nil? && facet_in_params?(facet_name, facet_config.boolean[:on])
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
