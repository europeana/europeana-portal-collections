class UpdateArtHistoryCollectionTranslation < ActiveRecord::Migration
  def change
    Collection.connection.execute("UPDATE collection_translations SET title = 'Art' WHERE title ='Art History'")
  end
end
