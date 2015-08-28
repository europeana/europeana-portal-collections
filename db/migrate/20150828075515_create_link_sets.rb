class CreateLinkSets < ActiveRecord::Migration
  def change
    create_table :link_sets do |t|
      t.timestamps null: false
    end

    change_table :links do |t|
      t.integer :set_id
      t.integer :position, index: true
    end
    add_foreign_key :links, :link_sets, column: :set_id

    change_table :landing_pages do |t|
      t.integer :credits_id
      t.integer :social_media_id
    end
    add_foreign_key :landing_pages, :link_sets, column: :credits_id
    add_foreign_key :landing_pages, :link_sets, column: :social_media_id
  end
end
