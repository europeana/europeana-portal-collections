# frozen_string_literal: true

class AddPositionToLinks < ActiveRecord::Migration
  def change
    add_column :links, :position, :integer
  end
end
