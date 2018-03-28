# frozen_string_literal: true

class DropCollectionsGalleriesTable < ActiveRecord::Migration
  def up
    drop_table :collections_galleries
  end

  def down
    create_table :collections_galleries do |t|
      t.belongs_to :collection, index: true
      t.belongs_to :gallery, index: true
    end
  end
end
