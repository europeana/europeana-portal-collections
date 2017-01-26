# frozen_string_literal: true
class CreateEuropeanaRecords < ActiveRecord::Migration
  def change
    create_table :europeana_records do |t|
      t.string :europeana_id
      t.index :europeana_id, unique: true
      t.json :metadata
      t.timestamps null: false
    end
  end
end
