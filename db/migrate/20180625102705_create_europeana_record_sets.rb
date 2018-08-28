# frozen_string_literal: true

class CreateEuropeanaRecordSets < ActiveRecord::Migration
  class Europeana::Record::Set < ActiveRecord::Base
    self.table_name = 'europeana_record_sets'
    translates :title
  end

  def change
    create_table :europeana_record_sets do |t|
      t.string :europeana_ids, array: true, null: false
      t.jsonb :settings
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        Europeana::Record::Set.create_translation_table!(title: :string)
      end
      dir.down do
        Europeana::Record::Set.drop_translation_table!
      end
    end
  end
end
