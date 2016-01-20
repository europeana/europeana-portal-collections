class AddSubjectTypeToBrowseEntries < ActiveRecord::Migration
  def change
    add_column :browse_entries, :subject_type, :integer, default: nil
    add_index :browse_entries, :subject_type
  end
end
