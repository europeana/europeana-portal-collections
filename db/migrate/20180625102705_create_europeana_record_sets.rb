# frozen_string_literal: true

class CreateEuropeanaRecordSets < ActiveRecord::Migration
  def change
    create_table :europeana_record_sets do |t|
      t.string :title, null: false
      t.string :europeana_ids, array: true, null: false
      t.string :settings
      t.timestamps null: false
    end
  end
end
