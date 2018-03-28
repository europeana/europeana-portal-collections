# frozen_string_literal: true

class AddSettingsToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :settings, :text
  end
end
