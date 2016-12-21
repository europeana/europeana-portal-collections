# frozen_string_literal: true
class BrowseEntry
  class FacetEntry < BrowseEntry
    validates :facet_field, inclusion: { in: :facet_field_enum_values }
    validates :facet_value, presence: true

    before_save :set_query

    delegate :facet_field_enum, :facet_field_enum_values, to: :class

    class << self
      def facet_field_enum
        PortalController.blacklight_config.facet_fields.keys.each_with_object({}) do |facet_field, h|
          ff = Europeana::Blacklight::Response::Facets::FacetField.new(facet_field, [])
          presenter = FacetPresenter.build(ff, PortalController.new, PortalController.blacklight_config)
          facet_title = presenter.facet_title || facet_field
          h[facet_title] = facet_field
        end
      end

      def facet_field_enum_values
        facet_field_enum.values
      end
    end

    def facet?
      true
    end

    def set_query
      entry_url = "f[#{facet_field}][]=#{facet_value}"
      self.query = entry_url
    end
  end
end
