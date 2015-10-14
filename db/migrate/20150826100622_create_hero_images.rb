class CreateHeroImages < ActiveRecord::Migration
  def change
    create_table :hero_images do |t|
      t.integer :media_object_id
      t.text :attribution
      t.text :brand
      t.string :license
      t.timestamps null: false
    end
    add_foreign_key :hero_images, :media_objects
  end
end
