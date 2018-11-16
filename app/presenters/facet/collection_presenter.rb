# frozen_string_literal: true

module Facet
  class CollectionPresenter < SimplePresenter
    def add_facet_url(item)
      fail NotImplementedError
    end

    def remove_facet_path(_item)
      search_path
    end

    def replace_facet_path(item)
      default_facet_value?(item.value) ? search_path : collection_path(item.value)
    end

    def add_facet_query(item, base: facet_item_url_base_query)
      fail NotImplementedError
    end

    def remove_facet_query(_item)
      facet_item_url_base_query
    end

    def replace_facet_query(_item)
      facet_item_url_base_query
    end

    def apply_order_to_items?
      true
    end

    def apply_order_to_items(items, **_)
      items.unshift(items.delete(items.detect { |item| facet_in_params?(facet_name, item) }))
    end

    def remove_facet_query(_item)
      facet_item_url_base_query
    end

    def facet_in_params?(field, item)
      facet_params(field) == item.value
    end

    def facet_params(_field)
      params[:controller] == 'collections' ? params[:id] : default_facet_value
    end
  end
end
