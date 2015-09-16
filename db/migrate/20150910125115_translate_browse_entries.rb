class TranslateBrowseEntries < ActiveRecord::Migration
  def self.up
    BrowseEntry.create_translation_table!({
      title: :string
    }, {
      migrate_data: true
    })
    remove_column :browse_entries, :title
  end

  def self.down
    add_column :browse_entries, :title, :string
    BrowseEntry.drop_translation_table! migrate_data: true
  end
end
