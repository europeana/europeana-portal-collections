class RemoveFacetFieldFromBrowseEntries < ActiveRecord::Migration
  def up
    remove_column :browse_entries, :facet_field
  end

  def down
    add_column :browse_entries, :facet_field, :string
  end
end
