# frozen_string_literal: true
class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :slug, index: true
      t.text :entity_uri
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        Topic.create_translation_table! label: :string
      end

      dir.down do
        Topic.drop_translation_table!
      end
    end
  end
end
