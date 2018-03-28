# frozen_string_literal: true

class SeedBrowseEntriesCollections < ActiveRecord::Migration
  def up
    execute "INSERT INTO browse_entries_collections (browse_entry_id, collection_id)
      SELECT be.id browse_entry_id, c.id collection_id
        FROM pages p
        INNER JOIN collections c ON p.slug=CONCAT('collections/', c.key)
        INNER JOIN page_elements pe ON pe.page_id=p.id
        INNER JOIN browse_entries be ON pe.positionable_id=be.id AND pe.positionable_type='BrowseEntry'
        WHERE p.type='Page::Landing';"
  end
end
