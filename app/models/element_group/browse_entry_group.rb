# frozen_string_literal: true

##
# A group of `BrowseEntry` items on a page.
#
class BrowseEntryGroup < ElementGroup
  has_many :browse_entries, through: :elements, source: :positionable, source_type: 'ElementGroup::BrowseEntry'

  validates :browse_entries, presence: true
  validates :title, presence: true

  acts_as_list scope: :page
end
