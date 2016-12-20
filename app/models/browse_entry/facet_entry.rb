# frozen_string_literal: true
class BrowseEntry
  class FacetEntry < BrowseEntry
    validates :facet_field, inclusion: { in: :facet_field_enum }
    validates :facet_value, presence: true

    before_save :set_query

    delegate :facet_field_enum, to: :class

    class << self
      def facet_field_enum
        PortalController.blacklight_config.facet_fields.keys
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
