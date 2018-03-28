# frozen_string_literal: true

class RemovePageIdAndPositionFromBrowseEntries < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.down do
        # PostgreSQL syntax
        execute "UPDATE browse_entries
                   SET page_id=page_elements.page_id, position=page_elements.position
                   FROM (SELECT * FROM page_elements WHERE positionable_type='BrowseEntry') page_elements
                   WHERE page_elements.positionable_id=browse_entries.id"
      end
    end
    remove_column :browse_entries, :page_id, :integer
    remove_column :browse_entries, :position, :integer
  end
end
