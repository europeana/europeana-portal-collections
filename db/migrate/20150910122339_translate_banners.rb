class TranslateBanners < ActiveRecord::Migration
  def self.up
    Banner.create_translation_table!({
      title: :string,
      body: :text
    }, {
      migrate_data: true
    })
  end

  def self.down
    Banner.drop_translation_table! migrate_data: true
  end
end
