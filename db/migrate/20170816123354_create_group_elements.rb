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
    end

    add_foreign_key :group_elements, :element_groups
    add_index :group_elements, [:positionable_id, :positionable_type]
    add_index :group_elements, :position

    BrowseEntry::FacetEntry.each do |facet_entry|
      GroupElement.create(group_id: facet_entry.facet_link_group_id, positionable_id: facet_entry.id, positionable_type: 'BrowseEntry::FacetEntry', position: facet_entry.position)
    end
    remove_foreign_key :browse_entries, :facet_link_groups
    remove_column :browse_entries, :facet_link_group_id
  end

  def down
    delete_table :group_elements
  end
end
