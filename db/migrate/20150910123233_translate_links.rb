class TranslateLinks < ActiveRecord::Migration
  def self.up
    Link.create_translation_table!({
      text: :text
    }, {
      migrate_data: true
    })
  end

  def self.down
    Link.drop_translation_table! migrate_data: true
  end
end
