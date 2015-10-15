class AddStateToBanner < ActiveRecord::Migration
  def change
    add_column :banners, :state, :integer, default: 0, index: true
  end
end
