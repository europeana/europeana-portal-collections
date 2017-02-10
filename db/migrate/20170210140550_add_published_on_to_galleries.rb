class AddPublishedOnToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :published_on, :datetime
  end
end
