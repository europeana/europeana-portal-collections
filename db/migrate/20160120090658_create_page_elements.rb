# frozen_string_literal: true

class CreatePageElements < ActiveRecord::Migration
  def change
    create_table :page_elements do |t|
      t.integer :page_id
      t.integer :positionable_id
      t.string :positionable_type
      t.integer :position
    end

    add_foreign_key :page_elements, :pages
    add_index :page_elements, %i(positionable_id positionable_type)
    add_index :page_elements, :position

    reversible do |dir|
      dir.up do
        execute "INSERT INTO page_elements (page_id, positionable_id, positionable_type, position) SELECT page_id, id, 'BrowseEntry', position FROM browse_entries"
      end
    end
  end
end
