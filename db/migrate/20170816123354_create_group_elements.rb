# frozen_string_literal: true

class CreateGroupElements < ActiveRecord::Migration
  def up
    create_table :group_elements do |t|
      t.integer :element_group_id
      t.string :element_group_type
      t.integer :groupable_id
      t.string :groupable_type
      t.integer :position
      t.timestamps null: false
    end
    add_index :group_elements, :id
    add_index :group_elements, [:groupable_type, :groupable_id], name: :index_groupables_on_groupable
    add_index :group_elements, [:groupable_type, :groupable_id, :element_group_type, :element_group_id, :position],
                               name: :index_groupables_on_group_position, unique: true
    add_foreign_key :group_elements, :element_groups
  end

  def down
    remove_foreign_key :group_elements, :element_groups
    drop_table :group_elements
  end
end
