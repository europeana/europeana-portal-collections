module Facet
  class CollectionPresenter < SimplePresenter
    def add_facet_params(item)
      value = facet_value_for_facet_item(item)

      if default_facet_value?(value)
        params.except(:id).merge(controller: :portal, action: :index)
      else
        params.merge(controller: :collections, action: :show, id: value)
      end
    end

    ##
    # Removing the collection facet only works when in a collection,
    # as it redirects to the standard search.
    # The only reason it takes a facet_item as a param is because
    # this overrides {FacetPresenter}
    #
    # @param see {#facet_item}
    # @return [Hash] Request parameters without the collection
    def remove_facet_params(_item)
      params.except(:id).merge(controller: :portal, action: :index)
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

    def ordered(*)
      super.tap do |items|
        if all = items.detect { |item| default_facet_value?(facet_value_for_facet_item(item)) }
          items.unshift(items.delete(all))
        end
      end
    end
  end
end
