# frozen_string_literal: true
class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :user_id, index: true
      t.references :permissionable, polymorphic: true
      t.index [:permissionable_type, :permissionable_id], name: :index_permissions_on_permissionable
      t.timestamps null: false
    end
    add_foreign_key :permissions, :users
  end
end
