# frozen_string_literal: true

class MigrateFacetLinkGroups < ActiveRecord::Migration
  def up
    FacetLinkGroup.all.each do |old_facet_link_group|
      page = old_facet_link_group.page_landing
      new_link_group = ElementGroup::FacetEntryGroup.new(
        facet_field: old_facet_link_group.facet_field,
        facet_values_count: old_facet_link_group.facet_values_count,
        thumbnails: old_facet_link_group.thumbnails)
      new_link_group.pages << page
      new_link_group.save!
      old_facet_link_group.browse_entry_facet_entries.each do |old_facet_entry|
        new_link_group.facet_link_elements << old_facet_entry
        new_link_group.save!
      end
    end
  end

  def down

  end
end
