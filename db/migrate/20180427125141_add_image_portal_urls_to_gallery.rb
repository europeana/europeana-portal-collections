class AddImagePortalUrlsToGallery < ActiveRecord::Migration
  def change
    add_column :galleries, :image_portal_urls, :text
  end
end
