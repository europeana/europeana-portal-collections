# frozen_string_literal: true

class AddTypeToLink < ActiveRecord::Migration
  def change
    add_column :links, :type, :string
  end
end
