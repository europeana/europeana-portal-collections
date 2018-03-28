# frozen_string_literal: true

class CreateFacetLinkGroups < ActiveRecord::Migration
  def up
    create_table :facet_link_groups do |t|
      t.string :facet_field
      t.integer :facet_values_count
      t.boolean :thumbnails
      t.integer :page_id

      t.timestamps
    end

    add_foreign_key :facet_link_groups, :pages, column: :page_id, primary_key: :id
  end

  def down
    drop_table :facet_link_groups
  end
end
