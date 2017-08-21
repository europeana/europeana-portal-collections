# frozen_string_literal: true

class CreateElementGroups < ActiveRecord::Migration
  def up
    create_table :element_groups do t
      t.integer :id, index: true
      t.string :facet_field
      t.integer :facet_values_count
      t.boolean :thumbnails
      t.string :type
      t.timestamps null: false
    end
  end

  def down
    delete_table :element_groups
  end
end
