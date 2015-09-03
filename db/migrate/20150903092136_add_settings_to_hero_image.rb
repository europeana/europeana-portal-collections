class AddSettingsToHeroImage < ActiveRecord::Migration
  def change
    add_column :hero_images, :settings, :text
    remove_column :hero_images, :attribution
    remove_column :hero_images, :brand
  end
end
