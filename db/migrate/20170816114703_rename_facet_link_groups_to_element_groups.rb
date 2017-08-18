class RenameFacetLinkGroupsToElementGroups < ActiveRecord::Migration
  def up
    Raise 'not ready yet, TODO migrate facet_browse entry points'
    remove_foreign_key :browse_entries, :facet_link_groups
    remove_column :browse_entries, :facet_link_group_id
    rename_table :facet_link_groups, :element_groups
    add_column :element_groups, :type, :string
  end
  def down
    remove_column :element_groups, :type, :string
    rename_table :facet_link_groups, :element_groups
    remove_foreign_key :browse_entries, :facet_link_groups
    remove_column :browse_entries, :facet_link_group_id

  end
end
