# frozen_string_literal: true

class RemoveKeyFromBanners < ActiveRecord::Migration
  def change
    remove_column :banners, :key, :string
  end
end
