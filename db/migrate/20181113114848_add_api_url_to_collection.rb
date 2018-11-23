# frozen_string_literal: true

class AddApiUrlToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :api_url, :string
  end
end
