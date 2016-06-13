module Facet
  class AliasPresenter < FacetPresenter
    def display(_options = {})
      aliased_presenter.display(options)
    end

    private

    def aliased_presenter
      @aliased_presenter ||= begin
        presenter = FacetPresenter.build(aliased_facet, @controller)
        presenter.name = facet_name
        presenter.facet_config.merge!(facet_config)
        presenter
      end
    end

    def aliased_facet
      @aliased_facet ||= facets_from_request.detect do |facet|
        blacklight_config.facet_fields[facet.name] == facet_config.aliases
      end
    end
  end
end
