class SeedSettingsFullWidthOnPages < ActiveRecord::Migration
  def change
    Page.find_each do |page|
      page.settings[:full_width] = '0'
      page.save
    end
  end
end
