# frozen_string_literal: true

##
# A group of `BrowseEntry` items on a page.
#
# * each group must only contain browse entries of one subject type
# * browse entries must be grouped in multiples of 3
# * the `title` attribute of the parent class, `PageElementGroup`, is reused to
#   store the subject type this group contains
class BrowseEntryGroup < PageElementGroup
  has_many :browse_entries, through: :elements, source: :positionable, source_type: 'BrowseEntry'

  delegate :title_enum, to: :class

  validate :browse_entries_are_of_same_subject_type
  validate :number_of_browse_entries_is_multiple_of_three

  validates :browse_entries, presence: true

  class << self
    def title_enum
      BrowseEntry.subject_types.keys
    end
  end

  validates :title, inclusion: { in: title_enum }

  acts_as_list scope: :page

  protected

  def browse_entries_are_of_same_subject_type
    if (browse_entries.map(&:subject_type) - [title]).size.nonzero?
      errors.add(:browse_entries, %(must all be of the same subject type, "#{title}"))
    end
  end

  def number_of_browse_entries_is_multiple_of_three
    unless (browse_entries.size % 3).zero?
      errors.add(:browse_entries, "need to be in groups of 3, you have provided #{browse_entries.count}")
    end
  end
end
