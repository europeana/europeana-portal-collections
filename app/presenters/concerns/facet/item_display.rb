# frozen_string_literal: true

module Facet
  module ItemDisplay
    extend ActiveSupport::Concern

    ##
    # Splits the facet's items into two sets, one to be shown, the other hidden
    #
    # All currently selected facet items will be shown, regardless of the value of
    # the `count` option.
    #
    # After all selected facet items, other non-selected facet items will be
    # included in the set to show, up to a maximum set by the `count` option.
    #
    # All other items will be in the hidden set.
    #
    # @return [Array<Array>] Two arrays of facet items, first to show, last to hide
    def items_to_show_and_hide(**options)
      options.reverse_merge!(count: 5)

      unhidden_items = []
      hidden_items = items_to_display

      unless facet_config.single
        hidden_items.select { |item| facet_in_params?(facet_name, item) }.each do |selected_item|
          unhidden_items << hidden_items.delete(selected_item)
        end
      end
      unhidden_items.push(hidden_items.shift) while (unhidden_items.size < options[:count]) && hidden_items.present?
      [unhidden_items, hidden_items]
    end

    # @return [Array<Europeana::Blacklight::Response::Facets::FacetItem>]
    def items_to_display
      items = facet_items.dup
      %i{only order splice format_value_as}.each do |mod|
        items = send(:"apply_#{mod}_to_items", items) if send(:"apply_#{mod}_to_items?")
      end
      items
    end

    def apply_only_to_items?
      facet_config.only.present?
    end

    def apply_order_to_items?
      false
    end

    def apply_splice_to_items?
      facet_config.splice.present? && facet_config.parent.present?
    end

    def apply_format_value_as_to_items?
      facet_config.format_value_as.present?
    end

    def apply_only_to_items(items)
      items.select { |item| facet_config.only.call(item) }
    end

    def apply_order_to_items(items)
      items
    end

    def apply_splice_to_items(items)
      items.select { |item| facet_config.splice.call(@parent, item) } if facet_config.splice.present?
    end

    def apply_format_value_as_to_items(items)
      items.map! do |item|
        item.value = facet_config.format_value_as.call(item.value)
        item
      end
    end
  end
end
