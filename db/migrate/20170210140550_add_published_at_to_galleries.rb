# frozen_string_literal: true
class AddPublishedAtToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :published_at, :datetime
  end
end
