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
    add
  end

  def down
    ElementGroup.drop_translation_table! migrate_data: true
    remove_index :element_groups, :id
    delete_table :element_groups
  end
end
