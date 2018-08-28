# frozen_string_literal: true

class AddAltLabelToEuropeanaRecordSets < ActiveRecord::Migration
  def change
    add_column(:europeana_record_set_translations, :alt_label, :string, array: true)
  end
end
