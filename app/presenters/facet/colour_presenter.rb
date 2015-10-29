module Facet
  class ColourPresenter < FacetPresenter
    def display
      super.merge(colour: true)
    end

    def facet_item(item)
      super.tap do |basic|
        basic.delete(:text)
        basic[:hex] = item.value
      end
    end
  end
end
