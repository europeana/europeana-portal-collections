# frozen_string_literal: true

class TranslateLinks < ActiveRecord::Migration
  def self.up
    Link.create_translation_table!({
                                     text: :text
                                   },
                                   migrate_data: true)
    remove_column :links, :text
  end

  def self.down
    add_column :links, :text, :text
    Link.drop_translation_table! migrate_data: true
  end
end
