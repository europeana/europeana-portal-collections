module Facet
  class CollectionPresenter < SimplePresenter
    def facet_item_url(item)
      search_action_url(add_facet_params(item))
    end

    def add_facet_params(item)
      value = facet_value_for_facet_item(item)

      if value == 'home'
        params.except(:id).merge(controller: :portal, action: :index)
      else
        params.merge(controller: :collections, action: :show, id: value)
      end
    end

    def facet_in_params?(field, item)
      value = facet_value_for_facet_item(item)

      facet_params(field) == value
    end

    def facet_params(_field)
      params[:controller] == 'collections' ? params[:id] : 'home'
    end

    def ordered(*)
      super.tap do |items|
        if home = items.detect { |item| facet_value_for_facet_item(item) == 'home' }
          items.unshift(items.delete(home))
        end
      end
    end
  end
end
