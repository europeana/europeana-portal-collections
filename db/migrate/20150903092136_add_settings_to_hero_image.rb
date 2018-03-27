# frozen_string_literal: true

class AddSettingsToHeroImage < ActiveRecord::Migration
  def change
    add_column :hero_images, :settings, :text
    remove_column :hero_images, :attribution, :text
    remove_column :hero_images, :brand, :text
  end
end
