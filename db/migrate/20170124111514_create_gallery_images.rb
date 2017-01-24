# frozen_string_literal: true
class CreateGalleryImages < ActiveRecord::Migration
  def change
    create_table :gallery_images do |t|
      t.integer :gallery_id
      t.integer :position, index: true
      t.string :record_url
      t.json :record_metadata
      t.timestamps null: false
    end
    add_foreign_key :gallery_images, :galleries
  end
end
