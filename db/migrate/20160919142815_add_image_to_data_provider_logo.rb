class AddImageToDataProviderLogo < ActiveRecord::Migration
  def up
    add_attachment :data_provider_logos, :image
  end

  def down
    remove_attachment :data_provider_logos, :image
  end
end
