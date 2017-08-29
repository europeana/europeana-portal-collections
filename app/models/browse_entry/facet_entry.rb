# frozen_string_literal: true
class BrowseEntry
  class FacetEntry < BrowseEntry
    validates :facet_value, presence: true

    #delegate :facet_field, to: :facet_entry_group

    belongs_to :facet_link_group

    has_many :facet_entry_group_elements, -> { where(groupable_type: 'BrowseEntry::FacetEntry') },
             class_name: 'GroupElement', dependent: :destroy, foreign_key: "groupable_id"
    has_many :facet_entry_groups, through: :facet_entry_group_elements, source: :element_group,
                                   source_type: 'ElementGroup::FacetEntryGroup',
                                   class_name: 'ElementGroup::FacetEntryGroup'#, foreign_key: 'element_group_id'
    has_many :facet_entry_group_page_elements, through: :facet_entry_groups, source: :page_elements, dependent: :destroy,
                                                as: :positionable
    has_many :facet_entry_group_pages, through: :element_group_page_elements, source: :page, class_name: 'Page::Landing'

    def facet_field
      facet_entry_groups.first.facet_field
    end

    def facet?
      true
    end

    # Overriding AR attribute accessor
    def query
      "q=&f[#{facet_field}][]=#{facet_value}&f[THUMBNAIL][]=true"
    end
  end
end
