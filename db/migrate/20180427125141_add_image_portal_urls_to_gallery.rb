# frozen_string_literal: true

class AddImagePortalUrlsToGallery < ActiveRecord::Migration
  def change
    add_column :galleries, :image_portal_urls, :string, array: true
  end
end
