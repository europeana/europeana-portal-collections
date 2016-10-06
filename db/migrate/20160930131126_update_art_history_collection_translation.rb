class UpdateArtHistoryCollectionTranslation < ActiveRecord::Migration
  def up
    Collection.connection.execute("UPDATE collection_translations SET title = 'Art' WHERE title ='Art History'")
  end

  def down
    Collection.connection.execute("UPDATE collection_translations SET title = 'Art History' WHERE title ='Art'")
  end
end
