class AddStateToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :state, :integer, default: 0, index: true
  end
end
