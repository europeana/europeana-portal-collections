# frozen_string_literal: true

class DropSessions < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.down do
        add_index :sessions, :session_id, unique: true
        add_index :sessions, :updated_at
      end
    end

    drop_table :sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.timestamps
    end
  end
end
