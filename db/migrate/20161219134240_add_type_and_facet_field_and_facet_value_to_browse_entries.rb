# frozen_string_literal: true

class AddTypeAndFacetFieldAndFacetValueToBrowseEntries < ActiveRecord::Migration
  def up
    add_column :browse_entries, :type, :string
    add_column :browse_entries, :facet_field, :string
    add_column :browse_entries, :facet_value, :string
  end

  def down
    remove_column :browse_entries, :type
    remove_column :browse_entries, :facet_field
    remove_column :browse_entries, :facet_value
  end
end
