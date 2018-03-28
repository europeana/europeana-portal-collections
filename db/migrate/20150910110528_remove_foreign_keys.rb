# frozen_string_literal: true

class RemoveForeignKeys < ActiveRecord::Migration
  def change
    remove_foreign_key 'browse_entries', 'landing_pages'
    remove_foreign_key 'browse_entries', 'media_objects'
    remove_foreign_key 'hero_images', 'media_objects'
    remove_foreign_key 'landing_pages', 'channels'
    remove_foreign_key 'landing_pages', 'hero_images'
    remove_foreign_key 'links', 'media_objects'
  end
end
