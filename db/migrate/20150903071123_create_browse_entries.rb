class CreateBrowseEntries < ActiveRecord::Migration
  def change
    create_table :browse_entries do |t|

      t.timestamps null: false
    end
  end
end
