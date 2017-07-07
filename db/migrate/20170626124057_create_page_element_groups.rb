# frozen_string_literal: true

class CreatePageElementGroups < ActiveRecord::Migration
  def change
    create_table :page_element_groups do |t|
      t.integer :page_id
      t.integer :position
      t.string :type

      t.timestamps null: false
    end

    add_index :page_element_groups, :page_id
    add_index :page_element_groups, :position
    add_index :page_element_groups, :type
    add_foreign_key :page_element_groups, :pages

    add_column :page_elements, :page_element_group_id, :integer
    add_index :page_elements, :page_element_group_id
    add_foreign_key :page_elements, :page_element_groups

    reversible do |dir|
      dir.up do
        PageElementGroup.create_translation_table! title: :string
      end

      dir.down do
        PageElementGroup.drop_translation_table!
      end
    end
  end
end
