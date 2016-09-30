class UpdateArtHistoryPage < ActiveRecord::Migration
  def change
    Page.connection.execute("UPDATE pages SET slug = 'collections/art' WHERE slug='collections/art-history'")
  end
end
