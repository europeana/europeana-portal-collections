# frozen_string_literal: true

##
# A group of `BrowseEntry` items on a page.
#
class ElementGroup
  class BrowseEntryGroup < ElementGroup
    has_many :browse_entries, through: :group_elements, source: :groupable,
                              source_type: 'BrowseEntry'

    validates :browse_entries, presence: true
    validates :title, presence: true

    def browse_entry_ids=(ids)
      super

      ids.reject(&:blank?).each_with_index do |id, index|
        element = group_elements.detect { |e| (e.groupable_type == 'BrowseEntry') && (e.groupable_id == id.to_i) }
        element.remove_from_list
        element.insert_at(index + 1)
      end
    end
  end
end
