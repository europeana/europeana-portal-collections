# frozen_string_literal: true

class AddStateToLandingPage < ActiveRecord::Migration
  def change
    add_column :landing_pages, :state, :integer, default: 0, index: true
  end
end
