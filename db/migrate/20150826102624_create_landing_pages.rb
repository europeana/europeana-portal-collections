# frozen_string_literal: true

class CreateLandingPages < ActiveRecord::Migration
  def change
    create_table :landing_pages do |t|
      t.integer :channel_id
      t.integer :hero_image_id
      t.timestamps null: false
    end
    add_foreign_key :landing_pages, :channels
    add_foreign_key :landing_pages, :hero_images
  end
end
