module Facet
  class AliasPresenter < FacetPresenter
    def display(*args)
      aliased_presenter.display(*args)
    end

    private

    def aliased_presenter
      @aliased_presenter ||= begin
        presenter = FacetPresenter.build(aliased_facet, @controller)
        presenter.facet_name = facet_name
        presenter.facet_config.merge!(facet_config)
        presenter
      end
    end

    def aliased_facet
      @aliased_facet ||= facets_from_request.detect do |facet|
        facet.name == facet_config.aliases
      end
    end
  end
end
