# frozen_string_literal: true

class CreateDataProviders < ActiveRecord::Migration
  def change
    create_table :data_providers do |t|
      t.string :name
      t.string :uri

      t.timestamps null: false
    end
    add_index :data_providers, :name, unique: true
    add_index :data_providers, :uri, unique: true
  end
end
