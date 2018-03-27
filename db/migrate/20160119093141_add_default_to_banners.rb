# frozen_string_literal: true

class AddDefaultToBanners < ActiveRecord::Migration
  class Banner < ActiveRecord::Base; end

  def change
    add_column :banners, :default, :boolean, default: false
    add_index :banners, :default

    Banner.find_by_key('phase-feedback').update_attributes(default: true)
  end
end
