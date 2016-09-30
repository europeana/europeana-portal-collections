class UpdateArtHistoryCollection < ActiveRecord::Migration
  def change
    Collection.connection.execute("UPDATE collections SET key = 'art' WHERE key ='art-history'")
  end
end
