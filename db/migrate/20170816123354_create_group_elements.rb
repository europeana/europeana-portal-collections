# frozen_string_literal: true

class CreateGroupElements < ActiveRecord::Migration
  def up
    create_table :group_elements do |t|
      t.integer :element_group_id
      t.string :element_group_type
      t.integer :positionable_id
      t.string :positionable_type
      t.integer :position
      t.timestamps null: false
    end
    add_index :group_elements, :id
    add_index :group_elements, [:element_group_type, :element_group_id], name: :index_groups_on_groupable
    add_index :group_elements, [:positionable_type, :positionable_id], name: :index_positionables_on_positionable
    add_index :group_elements, [:element_group_type, :element_group_id, :positionable_type, :positionable_id, :position],
            name: :index_groups_on_groupable_position, unique: true
    add_foreign_key :group_elements, :element_groups
  end

  def down
    remove_index :group_elements, :id
    remove_index :group_elements, :index_groups_on_groupable
    remove_index :group_elements, :index_positionables_on_positionable
    remove_index :group_elements, :index_groups_on_groupable_position
    delete_table :group_elements
  end
end
