# frozen_string_literal: true

class AddTitleToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :title, :string
    Collection.create_translation_table! title: :string
  end

  def down
    Collection.drop_translation_table!
    remove_column :collections, :title
  end
end
