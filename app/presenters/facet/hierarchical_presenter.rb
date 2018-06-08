# frozen_string_literal: true

module Facet
  class HierarchicalPresenter < FacetPresenter
    def display(**options)
      output = super.merge(hierarchical: true)

      if labeller[:collapsible].present?
        output[:hidden_item_data] = {
          label_show_specific: I18n.t(labeller[:collapsible][:show]),
          label_hide_specific: I18n.t(labeller[:collapsible][:hide]),
          has_subselection: any_child_item_checked?(output[:items])
        }
      end

      output
    end

    def facet_item(item)
      subfilters = item_children(item).map do |child|
        FacetPresenter.build(child, @controller, @blacklight_config, item).display
      end
      subfilters.reject! { |sf| sf[:items].blank? }

      {
        has_subfilters: subfilters.present?,
        filters: subfilters
      }.merge(super)
    end

    def item_children(item)
      facets_from_request(facet_field_names).select do |child|
        parent = @blacklight_config.facet_fields[child.name].parent
        if parent.is_a?(Array)
          (parent.first == @facet.name) && (parent.last == item.value)
        elsif !parent.nil?
          parent == @facet.name
        end
      end
    end

    def any_child_item_checked?(items)
      items.any? { |item| item[:filters].any? { |filter| filter[:items].any? { |child_item| child_item[:is_checked] } } }
    end

    ##
    # Removes all child facets from query string
    def remove_facet_query(item)
      super.tap do |query|
        item_children(item).each do |child|
          child_query = CGI.escape("f[#{child.name}][]")
          query.gsub!(/#{child_query}=[^&]+&?/, '')
        end
      end
    end
  end
end
