class CreateBrowseEntriesCollections < ActiveRecord::Migration
  def change
    create_table :browse_entries_collections do |t|
      t.integer :browse_entry_id
      t.integer :collection_id
    end

    add_foreign_key :browse_entries_collections, :browse_entries
    add_foreign_key :browse_entries_collections, :collections
  end
end
