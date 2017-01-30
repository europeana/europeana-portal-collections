# frozen_string_literal: true
class CreateGalleryImages < ActiveRecord::Migration
  def change
    create_table :gallery_images do |t|
      t.integer :gallery_id
      t.string :europeana_record_id
      t.integer :position, index: true
      t.timestamps null: false
    end
    add_foreign_key :gallery_images, :galleries
  end
end
