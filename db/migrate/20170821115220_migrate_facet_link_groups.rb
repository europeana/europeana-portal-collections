# frozen_string_literal: true

class MigrateFacetLinkGroups < ActiveRecord::Migration
  def up

    FacetLinkGroup.all.each do |old_facet_link_group|
      page = old_facet_link_group.page_landing
      new_entry_group = ElementGroup::FacetEntryGroup.create!(
        facet_field: old_facet_link_group.facet_field,
        facet_values_count: old_facet_link_group.facet_values_count,
        thumbnails: old_facet_link_group.thumbnails)

      page.element_groups << new_entry_group
      element = page.elements.detect { |e| (e.positionable_type.starts_with?('ElementGroup')) && (e.positionable_id == new_entry_group.id) }
      number_of_elements = page.element_groups.count
      element.remove_from_list
      element.insert_at(number_of_elements)

      old_facet_link_group.browse_entry_facet_entries.each do |old_facet_entry|
        new_entry_group.facet_entries << old_facet_entry
        group_element = new_entry_group.group_elements.detect do |e|
            (e.groupable_type == ('BrowseEntry::FacetEntry')) && (e.groupable_id == old_facet_entry.id)
        end
        number_of_group_elements = new_entry_group.facet_entries.count
        group_element.remove_from_list
        group_element.insert_at(number_of_group_elements)
      end
    end
  end

  def down
    # TODO
  end
end
