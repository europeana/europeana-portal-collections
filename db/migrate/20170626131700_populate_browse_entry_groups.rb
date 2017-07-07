# frozen_string_literal: true

class PopulateBrowseEntryGroups < ActiveRecord::Migration
  def up
    page_elements = PageElement.where(positionable_type: 'BrowseEntry').where.not(page_id: nil)
    page_elements.group_by(&:page_id).each_pair do |page_id, page_elements_for_page_id|
      page_elements_for_page_id.group_by { |pe| pe.positionable.subject_type }.each_pair do |subject_type, page_elements_for_browse_entry_subject_type|
        position = case subject_type
                   when 'person'
                     1
                   when 'topic'
                     2
                   when 'period'
                     3
                   end

        puts %(Creating browse entry group with subject type "#{subject_type}" for page ID #{page_id})
        BrowseEntryGroup.new(page_id: page_id, position: position, title: subject_type).tap do |group|
          group.elements = page_elements_for_browse_entry_subject_type
          group.browse_entries = page_elements_for_browse_entry_subject_type.map(&:positionable)
          group.save!(validate: false)
        end
      end
    end
  end

  def down
    PageElement.where(positionable_type: 'BrowseEntry').update_all(page_element_group_id: nil)
    BrowseEntryGroup.destroy_all
  end
end
