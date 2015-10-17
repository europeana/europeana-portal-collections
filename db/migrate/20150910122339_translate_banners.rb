class TranslateBanners < ActiveRecord::Migration
  def self.up
    Banner.create_translation_table!({
      title: :string,
      body: :text
    }, {
      migrate_data: true
    })
    remove_column :banners, :title
    remove_column :banners, :body
  end

  def self.down
    add_column :banners, :title, :string
    add_column :banners, :body, :text
    Banner.drop_translation_table! migrate_data: true
  end
end
