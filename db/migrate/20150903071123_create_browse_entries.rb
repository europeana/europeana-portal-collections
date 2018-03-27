# frozen_string_literal: true

class CreateBrowseEntries < ActiveRecord::Migration
  def change
    create_table :browse_entries do |t|
      t.string :title
      t.text :query
      t.references :landing_page, foreign_key: true, index: true
      t.references :media_object, foreign_key: true, index: true
      t.integer :position
      t.text :settings
      t.timestamps null: false
    end
  end
end
