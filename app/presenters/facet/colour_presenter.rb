module Facet
  class ColourPresenter < FacetPresenter
    def display(**options)
      options.reverse_merge!(count: facet_config.limit) unless facet_config.limit.nil?
      super(**options).merge(colour: true)
    end

    def facet_item(item)
      super.tap do |basic|
        basic.delete(:text)
        basic[:hex] = item.value
      end
    end
  end
end
