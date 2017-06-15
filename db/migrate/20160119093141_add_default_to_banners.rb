class AddDefaultToBanners < ActiveRecord::Migration
  class Banner < ActiveRecord::Base; end

  def change
    add_column :banners, :default, :boolean, default: false
    add_index :banners, :default

    banner = Banner.find_by_key('phase-feedback')
    banner.update_attributes(default: true) if banner
  end
end
