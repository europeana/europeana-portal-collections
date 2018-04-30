class AddImageErrorsToGallery < ActiveRecord::Migration
  def change
    add_column :galleries, :image_errors, :json
  end
end
