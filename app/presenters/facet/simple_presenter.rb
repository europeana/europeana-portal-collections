# frozen_string_literal: true

module Facet
  class SimplePresenter < FacetPresenter
    def display(**options)
      super.merge(simple: true)
    end
  end
end
