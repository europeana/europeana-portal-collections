class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.integer :hero_image_id, index: true
      t.string :slug, index: true
      t.integer :state, default: 0, index: true
      t.string :type
      t.integer :http_code, index: true
      t.timestamps null: false
    end
    Page.create_translation_table! title: :string, body: :text

    drop_table :landing_pages

    rename_column :browse_entries, :landing_page_id, :page_id
  end

  def down
    drop_table :pages
    Page.drop_translation_table!

    rename_column :browse_entries, :page_id, :landing_page_id

    create_table :landing_pages do |t|
      t.integer  :channel_id, index: true
      t.integer  :hero_image_id, index: true
      t.integer :state, default: 0, index: true
      t.timestamps null: false
    end
  end
end
