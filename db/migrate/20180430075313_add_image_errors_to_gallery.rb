# frozen_string_literal: true

class AddImageErrorsToGallery < ActiveRecord::Migration
  def change
    add_column :galleries, :image_errors, :jsonb
  end
end
