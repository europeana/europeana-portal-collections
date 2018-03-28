# frozen_string_literal: true

class AddSlugToGallery < ActiveRecord::Migration
  def change
    add_column :galleries, :slug, :text
    add_index :galleries, :slug, unique: true
  end
end
