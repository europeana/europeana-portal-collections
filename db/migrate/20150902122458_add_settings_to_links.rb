class AddSettingsToLinks < ActiveRecord::Migration
  def change
    add_column :links, :settings, :text
  end
end
