# frozen_string_literal: true
class AssociateGalleryWithCollection < ActiveRecord::Migration
  def change
    create_table :collections_galleries do |t|
      t.belongs_to :collection, index: true
      t.belongs_to :gallery, index: true
    end
  end
end
