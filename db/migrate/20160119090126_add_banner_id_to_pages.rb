class AddBannerIdToPages < ActiveRecord::Migration
  def change
    add_column :pages, :banner_id, :integer
    add_index :pages, :banner_id
    add_foreign_key :pages, :banners
  end
end
