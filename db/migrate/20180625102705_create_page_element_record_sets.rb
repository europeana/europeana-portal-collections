# frozen_string_literal: true

class CreatePageElementRecordSets < ActiveRecord::Migration
  def change
    create_table :page_element_record_sets do |t|
      t.integer :page_id, index: true, null: false
      t.string :title, null: false
      t.string :europeana_ids, :string, array: true, null: false
      t.string :settings
      t.timestamps null: false
    end
    add_foreign_key :page_element_record_sets, :pages
  end
end
