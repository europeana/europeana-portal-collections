# frozen_string_literal: true

##
# A group of `BrowseEntry` items on a page.
#
class ElementGroup
  class BrowseEntryGroup < ElementGroup
    has_many :browse_entry_elements, -> { order(:position) }, as: :groupable, class_name: 'GroupElement',
                                                              dependent: :destroy
    has_many :browse_entries, through: :browse_entry_elements, source: :groupable,
                              source_type: 'BrowseEntry'

    validates :browse_entries, presence: true
    validates :title, presence: true

    acts_as_list scope: :page
  end
end
