# frozen_string_literal: true

class CreateElementGroups < ActiveRecord::Migration
  def up
    create_table :element_groups do |t|
      t.string :facet_field
      t.integer :facet_values_count
      t.boolean :thumbnails
      t.string :type
      t.timestamps null: false
    end
    add_index :element_groups, :id
    ElementGroup.create_translation_table! title: :string
  end

  def down
    ElementGroup.drop_translation_table! migrate_data: true
    drop_table :element_groups
    execute "DELETE from page_elements where positionable_type = 'ElementGroup'"
  end
end
