# frozen_string_literal: true

class AddSettingsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :settings, :text
  end
end
