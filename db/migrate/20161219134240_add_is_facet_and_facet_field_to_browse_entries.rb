class AddIsFacetAndFacetFieldToBrowseEntries < ActiveRecord::Migration
  def up
    add_column :browse_entries, :is_facet, :boolean
    add_column :browse_entries, :facet_field, :string
  end

  def down
    remove_column :browse_entries, :is_facet
    remove_column :browse_entries, :facet_field
  end
end
