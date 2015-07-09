class CreateMediaObjects < ActiveRecord::Migration
  def change
    create_table :media_objects do |t|
      t.text :source_url
      t.string :source_url_hash, limit: 32, index: :unique
      t.attachment :file
      t.timestamps null: false
    end
  end
end
