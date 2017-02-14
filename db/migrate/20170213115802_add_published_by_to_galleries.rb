# frozen_string_literal: true
class AddPublishedByToGalleries < ActiveRecord::Migration
    def up
      add_column :galleries, :published_by, :integer
      add_index :galleries, :published_by
      add_foreign_key :galleries, :users, column: :published_by
    end

    def down
      remove_column :galleries, :published_by, :integer
    end
end
