# frozen_string_literal: true

class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.integer :state, default: 0, index: true
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        Gallery.create_translation_table! title: :string, description: :text
      end

      dir.down do
        Gallery.drop_translation_table!
      end
    end
  end
end
