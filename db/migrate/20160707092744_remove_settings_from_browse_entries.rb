# frozen_string_literal: true

class RemoveSettingsFromBrowseEntries < ActiveRecord::Migration
  def change
    remove_column :browse_entries, :settings, :text
  end
end
