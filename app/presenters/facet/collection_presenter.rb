# frozen_string_literal: true

module Facet
  class CollectionPresenter < SimplePresenter
    def add_facet_url(item)
      value = facet_value_for_facet_item(item)
      base_url = default_facet_value?(value) ? search_url : collection_url(value)
      [base_url, facet_item_url_base_query].join('?')
    end

    def apply_order_to_items?
      true
    end

    def remove_facet_url(_item)
      [search_url, facet_item_url_base_query].reject(&:blank?).join('?')
    end

    def filter_items
      items_in_params.reject { |item| default_facet_value?(item.value) }.map { |item| filter_item(item) }
    end

    def facet_in_params?(field, item)
      value = facet_value_for_facet_item(item)

      facet_params(field) == value
    end

    def default_facet_value?(value)
      value == default_facet_value
    end

    def default_facet_value
      'all'
    end

    def facet_params(_field)
      params[:controller] == 'collections' ? params[:id] : default_facet_value
    end
  end
end
