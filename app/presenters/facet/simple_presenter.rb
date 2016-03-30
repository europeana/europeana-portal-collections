module Facet
  class SimplePresenter < FacetPresenter
    def display(_options = {})
      super.merge(simple: true)
    end
  end
end
