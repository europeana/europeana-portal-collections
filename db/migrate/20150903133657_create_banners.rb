# frozen_string_literal: true

class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :key, index: true
      t.string :title
      t.text :body
      t.timestamps null: false
    end
  end
end
