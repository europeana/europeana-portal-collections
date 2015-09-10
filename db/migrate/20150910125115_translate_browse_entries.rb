class TranslateBrowseEntries < ActiveRecord::Migration
  def self.up
    BrowseEntry.create_translation_table!({
      title: :string
    }, {
      migrate_data: true
    })
  end

  def self.down
    BrowseEntry.drop_translation_table! migrate_data: true
  end
end
