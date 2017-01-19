# frozen_string_literal: true
class BrowseEntry
  class FacetEntry < BrowseEntry
    validates :facet_value, presence: true
    validates :facet_link_group_id, presence: true

    delegate :facet_field, to: :facet_link_group

    belongs_to :facet_link_group

    before_save :set_query

    def facet?
      true
    end

    def set_query
      entry_url = "q=&f[#{facet_field}][]=#{facet_value}"
      self.query = entry_url
    end
  end
end
