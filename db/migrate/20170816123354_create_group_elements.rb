# frozen_string_literal: true

class CreateGroupElements < ActiveRecord::Migration
  def up
    create_table :group_elements do |t|
      t.integer :id
      t.integer :element_group_id
      t.string :element_group_type
      t.index [:element_group_type, :element_group_id], name: :index_groups_on_groupable
      t.integer :positionable_id
      t.string :positionable_type
      t.index [:positionable_type, :positionable_id], name: :index_positionables_on_positionable
      t.integer :position
      t.index [:element_group_type, :element_group_id, :positionable_type, :positionable_id, :position], unique: true,
              name: :index_groups_on_groupable
      t.timestamps null: false
    end

    add_foreign_key :group_elements, :element_groups
  end

  def down
    delete_table :group_elements
  end
end
