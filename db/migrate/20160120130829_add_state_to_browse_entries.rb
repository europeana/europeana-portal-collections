# frozen_string_literal: true

class AddStateToBrowseEntries < ActiveRecord::Migration
  def change
    add_column :browse_entries, :state, :integer, default: 0
    reversible do |dir|
      dir.up do
        execute 'UPDATE browse_entries SET state=1'
      end
    end
  end
end
