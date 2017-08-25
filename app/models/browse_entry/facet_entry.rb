# frozen_string_literal: true
class BrowseEntry
  class FacetEntry < BrowseEntry
    validates :facet_value, presence: true

    delegate :facet_field, to: :facet_link_group

    belongs_to :facet_link_group

    has_many :facet_entry_group_elements, class_name: 'GroupElement', dependent: :destroy, as: :groupable
    has_many :facet_entry_groups, through: :facet_entry_group_elements, source: :groupable,
                                  source_type: 'ElementGroup::FacetEntryGroup',
      class_name: 'ElementGroup::FacetEntryGroup', as: :positionable#, class_name: 'ElementGroup'
    has_many :facet_entry_group_page_elements, through: :facet_entry_groups, source: :page_elements, dependent: :destroy,
             as: :positionable
    has_many :facet_entry_group_pages, through: :element_group_page_elements, source: :page, class_name: 'Page::Landing'


    #def groupable_type=(class_name)
    #  super(class_name.constantize.base_class.to_s)
    #end

    def facet?
      true
    end

    # Overriding AR attribute accessor
    def query
      "q=&f[#{facet_field}][]=#{facet_value}&f[THUMBNAIL][]=true"
    end
  end
end
