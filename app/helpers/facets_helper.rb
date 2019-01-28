# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  # Overriding Blacklight's to account for our "aliased" fields
  def facet_by_field_name(field_or_field_name)
    case field_or_field_name
    when String, Symbol, Blacklight::Configuration::FacetField
      facet_field = facet_configuration_for_field(field_or_field_name)
      if facet_field.aliases.present?
        if aliased = @response.aggregations[facet_field.aliases]
          aliased.class.new(facet_field.key, aliased.items)
        end
      else
        @response.aggregations[facet_field.key]
      end
    else
      # is this really a useful case?
      field_or_field_name
    end
  end

  # Overriding Blacklight's for case-insensitive test
  def facet_in_params?(field, item)
    value = facet_value_for_facet_item(item)

    Array((facet_params(field) || [])).map(&:downcase).include? value.downcase
  end
end
