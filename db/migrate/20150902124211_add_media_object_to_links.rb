# frozen_string_literal: true

class AddMediaObjectToLinks < ActiveRecord::Migration
  def change
    add_reference :links, :media_object, foreign_key: true, index: true
  end
end
