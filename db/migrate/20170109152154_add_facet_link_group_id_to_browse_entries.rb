class AddFacetLinkGroupIdToBrowseEntries < ActiveRecord::Migration
  def up
    add_column :browse_entries, :facet_link_group_id, :integer
    add_foreign_key :browse_entries, :facet_link_groups
  end

  def down
    remove_foreign_key :browse_entries, :facet_link_groups
    remove_column :browse_entries, :facet_link_group_id
  end
end
