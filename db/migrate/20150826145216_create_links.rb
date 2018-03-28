# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :text
      t.text :url
      t.timestamps null: false
    end
  end
end
