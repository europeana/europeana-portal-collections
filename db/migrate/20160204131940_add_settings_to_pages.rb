class AddSettingsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :settings, :text
  end
end
