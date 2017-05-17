# frozen_string_literal: true
class BrowseEntry
  class FacetEntry < BrowseEntry
    validates :facet_value, presence: true
    validates :facet_link_group_id, presence: true

    delegate :facet_field, to: :facet_link_group

    belongs_to :facet_link_group

    def facet?
      true
    end

    # Overriding AR attribute accessor
    def query
      "q=&f[#{facet_field}][]=#{facet_value}&f[THUMBNAIL][]=true"
    end
  end
end
